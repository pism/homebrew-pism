class Petsc4py < Formula
  desc "Portable, Extensible Toolkit for Scientific Computation (Python bindings)"
  homepage "https://petsc.org/"
  url "https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.23.4.tar.gz"
  sha256 "711b2ad46b14f12fe74fcbc7f9b514444646f1e7b20ed57dc7482d34dfc4ca77"
  license "BSD-2-Clause"

  depends_on "cython" => :build
  depends_on "python-setuptools" => :build
  depends_on "numpy"
  depends_on "petsc"
  depends_on "python@3.13"

  def install
    ENV["PETSC_DIR"] = Formula["petsc"].prefix.realpath

    cd "src/binding/petsc4py" do
      system "python3", "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
    end
  end

  test do
    assert_match version.to_s, Formula["petsc"].version.to_s

    system "python3", "-c", "import petsc4py, sys; petsc4py.init(sys.argv)"
  end
end
