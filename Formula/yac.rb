class Yac < Formula
  desc "YAC - Yet Another Coupler"
  homepage "https://dkrz-sw.gitlab-pages.dkrz.de/yac/index.html"
  url "https://gitlab.dkrz.de/dkrz-sw/yac/-/archive/release-3.8.0/yac-release-3.8.0.tar.gz"
  sha256 "71a897bb704d43a6af04586c2639709b12459586335e9caf8d7e0d1adef3090e"
  license "BSD-3-Clause"

  depends_on "gcc"              # for the Fortran compiler
  depends_on "open-mpi"
  depends_on "yaxt"
  depends_on "libfyaml"

  def install
    system "./configure", "CC=mpicc", "FC=mpif90",
           "--with-external-lapack=no",
           "--disable-netcdf",
           "--disable-examples",
           "--disable-tools",
           "--disable-deprecated",
           "--with-pic",
           "--disable-silent-rules", *std_configure_args
    system "make", "install"

    inreplace (lib/"pkgconfig").glob("*.pc") do |s|
      s.gsub! prefix, opt_prefix
    end
  end

  test do
    system "false"
  end
end
