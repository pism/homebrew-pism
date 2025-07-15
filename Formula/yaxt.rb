class Yaxt < Formula
  desc "Yet Another eXchange Tool"
  homepage "https://dkrz-sw.gitlab-pages.dkrz.de/yaxt/index.html"
  url "https://gitlab.dkrz.de/dkrz-sw/yaxt/-/archive/release-0.11.4/yaxt-release-0.11.4.tar.gz"
  sha256 "44ce037b8e004428111aeea99a4552a573cccc5ecc793d374d76e79c8c02504e"
  license "BSD-3-Clause"

  depends_on "gcc" # for the Fortran compiler
  depends_on "open-mpi"

  def install
    system "./configure", "--with-pic", "--disable-silent-rules", *std_configure_args
    system "make", "install"

    inreplace (lib/"pkgconfig").glob("*.pc") do |s|
      s.gsub! prefix, opt_prefix
    end
  end

  test do
    system "false"
  end
end
