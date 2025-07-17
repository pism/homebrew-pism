class Pism < Formula
  desc "Parallel Ice Sheet Model (PISM)"
  homepage "https://pism.io/"
  url "https://github.com/pism/pism/archive/refs/tags/v2.2.2.tar.gz"
  sha256 "bbd64f767ced12bdc5667488a48021c1a96fbce8771489d4923317cdc16b5271"
  license "GPL-3.0-or-later"
  head "https://github.com/pism/pism.git", branch: "dev"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "swig" => :build
  depends_on "fftw"
  depends_on "gsl"
  depends_on "netcdf-mpi"
  depends_on "open-mpi"
  depends_on "petsc"
  depends_on "petsc4py"
  depends_on "proj"
  depends_on "python@3.13"
  depends_on "udunits"
  depends_on "yac"
  depends_on "yaxt"

  def install
    args = %w[]

    args << "-DCMAKE_C_COMPILER=mpicc"
    args << "-DCMAKE_CXX_COMPILER=mpicxx"
    args << "-DUDUNITS2_ROOT=#{Formula["udunits"].opt_prefix}"
    args << "-DPython3_EXECUTABLE=#{Formula["python@3.13"].opt_prefix}/bin/python3"
    args << "-DPism_USE_PROJ=YES"
    args << "-DPism_USE_YAC_INTERPOLATION=YES"
    args << "-DPism_USE_PARALLEL_NETCDF4=YES"
    args << "-DPism_BUILD_PYTHON_BINDINGS=YES"

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace (lib/"pkgconfig").glob("*.pc") do |s|
      s.gsub! prefix, opt_prefix
    end
  end

  test do
    # Run test G and compare reported errors
    output = shell_output("#{bin}/pism -test G -y 1000 -Mx 51 -My 51 -verbose 1 -o output.nc")

    assert_path_exists testpath/"output.nc"

    geometry_errors = output.lines[2].strip.squeeze(" ")
    assert_equal geometry_errors, "0.659590 26.185380 6.186086 0.013148"

    temperature_errors = output.lines[4].strip.squeeze(" ")
    assert_equal temperature_errors, "0.782424 0.220410 0.671583 0.138714"

    sigma_errors = output.lines[6].strip.squeeze(" ")
    assert_equal sigma_errors, "7.258858 0.890887"

    surface_velocity_errors = output.lines[8].strip.squeeze(" ")
    assert_equal surface_velocity_errors, "0.940931 0.193252 0.033099 0.004403"

    (testpath/"test_pism.py").write <<~PY
      print("Testing Python bindings...")
      import PISM
      ctx = PISM.Context()
      Lx = 1e5
      Ly = Lx
      Mx = 101
      My = Mx
      grid = PISM.Grid_Shallow(ctx.ctx, Lx, Ly, 0, 0, Mx, My, PISM.CELL_CORNER, PISM.NOT_PERIODIC)
      grid.report_parameters()
    PY

    system "python3", "test_pism.py"
  end
end
