class Pism < Formula
  desc "Parallel Ice Sheet Model (PISM)"
  homepage "https://pism.io/"
  url "https://github.com/pism/pism/archive/refs/tags/v2.1.tar.gz"
  sha256 "9d7e9854b58180df58d38fdd3eaa993a1e247548dfe183a8753a3f15190b6aaa"
  license "GPL-3.0-or-later"
  head "https://github.com/pism/pism.git", branch: "dev"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "gsl"
  depends_on "netcdf"
  depends_on "open-mpi"         # the petsc formula uses open-mpi, so we have to use it too
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

  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test pism`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
