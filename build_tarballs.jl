# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libyaml"
version = v"0.2.1"

# Collection of sources required to build libyaml
sources = [
    "https://github.com/yaml/libyaml/archive/0.2.1.tar.gz" =>
    "1d2aeb87f7d317f1496e4c39410d913840714874a354970300f375eec9303dc4",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd libyaml-0.2.1
./bootstrap
./configure --prefix=$prefix --host=$target
make
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms_base = [
    FreeBSD(:x86_64),
    Linux(:aarch64, libc=:glibc),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    Linux(:i686, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:x86_64, libc=:musl),
]
platforms_osx = [
    MacOS(:x86_64),
]

os = get(ENV, "TRAVIS_OS_NAME", nothing)
if os == "linux"
    platforms = platforms_base
elseif os == "osx"
    platforms = platforms_osx
else
    platforms = [platforms_base; platforms_osx]
end

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libyaml", :libyaml)
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(
    ARGS, name, version, sources, script, platforms, products, dependencies)
