class Pism < Formula
  desc "Parallel Ice Sheet Model (PISM)"
  homepage "https://pism.io/"
  url "https://github.com/pism/pism/archive/refs/tags/v2.2.2.tar.gz"
  sha256 "bbd64f767ced12bdc5667488a48021c1a96fbce8771489d4923317cdc16b5271"
  license "GPL-3.0-or-later"
  head "https://github.com/pism/pism.git", branch: "dev"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "gsl"
  depends_on "netcdf-mpi"
  depends_on "open-mpi"
  depends_on "petsc"
  depends_on "udunits"
  depends_on "pnetcdf" => :optional
  depends_on "proj" => :optional

  def install
    args = %w[]

    args << "-DPism_USE_PROJ=YES" if build.with? "proj"
    args << "-DPism_USE_PNETCDF=YES" if build.with? "pnetcdf"

    ENV["CC"] = "mpicc"
    ENV["CXX"] = "mpicxx"

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace (lib/"pkgconfig").glob("*.pc") do |s|
      s.gsub! prefix, opt_prefix
    end

    # remove the non-executable script that should not have been
    # installed in the first place
    rm_f("#{bin}/convert_config.py")
  end

  test do
    # Run test G and compare reported errors
    output = shell_output("#{bin}/pismv -test G -y 1000 -Mx 51 -My 51 -verbose 1 -o output.nc")

    assert_predicate testpath/"output.nc", :exist?

    geometry_errors = output.lines[2].strip.squeeze(" ")
    assert_equal geometry_errors, "0.659590 26.185380 6.186086 0.013148"

    temperature_errors = output.lines[4].strip.squeeze(" ")
    assert_equal temperature_errors, "0.782424 0.220410 0.671583 0.138714"

    sigma_errors = output.lines[6].strip.squeeze(" ")
    assert_equal sigma_errors, "7.258858 0.890887"

    surface_velocity_errors = output.lines[8].strip.squeeze(" ")
    assert_equal surface_velocity_errors, "0.940931 0.193252 0.033099 0.004403"
  end
end
