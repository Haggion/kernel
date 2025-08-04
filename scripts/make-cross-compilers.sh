# For cross compiling from apple silicon to risc-v 64bit
# This requires MPC, GMP, and whatever that other one is called, which I obtained from macports

# command line options look like this:
# ./scripts/make-cross-compilers.sh b gcc configure-gcc copy-dance configure-gnat clean gcc-stage-2
# where are arguments are positional and are not enabled if their value is not equal to that listed above
# b: build binutils
# gcc: build gcc (first stage, without gnat)
# configure-gcc: configure gcc (first stage)
# copy-dance: whether to copy the fake libbacktrace to the build (may not work without)
# configure-gnat: configure gcc (second stage, with gnat)
# clean: whether to delete old build files
# gcc-stage-2: build gcc (second stage, with gnat)

# I'm using this: https://github.com/simonjwright/distributing-gcc/releases/tag/gcc-14.2.0-3-aarch64
# note that by default gcc will point to XCode tools rather than actual gcc, so it's gotta be specified
gcc_install = "/opt/gcc-14.2.0-3-aarch64/bin/"

PATH="${gcc_install}:$PATH"
#PATH="/opt/local/:$PATH"
#PATH="${HOME}/cc_src/gnat/bin/:$PATH"

export CC="${gcc_install}gcc"
export LD="${gcc_install}gcc"
export CXX="${gcc_install}g++"
export CPP="${gcc_install}cpp"

export LD_LIBRARY_PATH=/opt/gcc-14.2.0-3-aarch64/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=/opt/gcc-14.2.0-3-aarch64/lib:$DYLD_LIBRARY_PATH

export CFLAGS="-funwind-tables -fPIC"
export ac_cv_func_backtrace=yes

export LDFLAGS="-L/opt/homebrew/Cellar/libiconv/1.18/lib"
export CPPFLAGS="-I/opt/homebrew/Cellar/libiconv/1.18/include"

export CFLAGS_FOR_TARGET="-g -O2"
export CXXFLAGS_FOR_TARGET="-g -O2"

export LIBS="-liconv"
export GNATLINKFLAGS="-liconv"
export GNATLINK="${gcc_install}g++ -liconv"

# libiconv installed by default on mac is outdated, so a more recent one needs to be installed
iconv="/opt/homebrew/Cellar/libiconv/1.18/"

export BUILD_TARGET="riscv64-none-elf"
export BUILD_PREFIX="${HOME}/opt/cross/${BUILD_TARGET}"
#export HOST="aarch64-apple-darwin24"

export PATH="{$BUILD_PREFIX}/bin:${PATH}"

concurrency=8 # makes stuff faster

local_lib_dir="/opt/homebrew/Cellar/" # location of local library dependences

source_dir="${HOME}/cc_src"
build_dir="${HOME}/cc_src/build"

binutils_version="2.44"
gcc_version="14.1.0"

# build GNU binutils
binutils_dir="binutils-${binutils_version}"

if [ "$6" == "clean" ]; then
  echo "Cleaning build directory..."
  rm -rf "${build_dir}/${gcc_dir}"/*
fi

cd "${build_dir}" || exit 1

if [[ ! -d "${build_dir}/${binutils_dir}" ]]; then
	mkdir "${build_dir}/${binutils_dir}" || exit 1
fi

cd "${build_dir}/${binutils_dir}" || exit 1

if [ "$1" == "b" ]; then
${source_dir}/${binutils_dir}/configure	\
	--target="${BUILD_TARGET}"	\
	--prefix="${BUILD_PREFIX}"	\
	--disable-nls			\
	--disable-multilib		\
	--disable-shared		\
	--with-sysroot || exit 1

#gmake configure-host || exit 1
gmake -j${concurrency} || exit 1
gmake -j${concurrency} install || exit 1
fi

# make gcc
gcc_dir="gcc-${gcc_version}"

cd "${build_dir}" || exit 1

if [[ ! -d "${build_dir}/${gcc_dir}" ]]; then
	mkdir "${build_dir}/${gcc_dir}" || exit 1
fi

cd "${build_dir}/${gcc_dir}" || exit 1

if [ "$3" == "configure-gcc" ]; then
${source_dir}/${gcc_dir}/configure	\
	--target="${BUILD_TARGET}"	\
	--prefix="${BUILD_PREFIX}"	\
	--enable-languages="c"		\
	--disable-multilib		\
	--disable-shared		\
	--disable-nls			\
	--with-gmp=/opt/local/		\
	--with-newlib			\
	--disable-hosted-libstdcxx	\
	--disable-libstdcxx-pch		\
	--disable-libstdcxx-verbose	\
	--disable-libstdcxx-debug	\
	--disable-libssp \
	--disable-libquadmath \
	--disable-libgomp \
	--disable-libgcov	\
	--disable-libatomic \
	--disable-libsanitizer \
	--disable-libvtv \
	--without-headers || exit 1
fi

# 	--with-libiconv-prefix="${iconv}" \

if [ "$2" == "gcc" ]; then
gmake -j${concurrency} all-gcc

if [ "$4" == "copy-dance" ]; then
# we don't want libbacktrace, but it refuses to listen to our flags, so this puts a fake one in there to shut it up
cp ~/Documents/Programming/kernel/fake-libbacktrace/libbacktrace.a ~/cc_src/build/gcc-14.1.0/libbacktrace/.libs
gmake -j${concurrency} all-gcc || exit 1
fi

gmake -j${concurrency} install-gcc || exit 1
fi

# make gnat

echo ""
echo ""
echo "======== BEGIN MAKE GNAT ========"
echo ""
echo ""

gcc_dir="gcc-${gcc_version}"

cd "${build_dir}" || exit 1

if [[ ! -d "${build_dir}/${gcc_dir}" ]]; then
	mkdir "${build_dir}/${gcc_dir}" || exit 1
fi

cd "${build_dir}/${gcc_dir}" || exit 1

if [ "$5" == "configure-gnat" ]; then
${source_dir}/${gcc_dir}/configure	\
	--target="${BUILD_TARGET}"	\
	--prefix="${BUILD_PREFIX}"	\
	--enable-languages="c,c++,ada"	\
	--disable-libada		\
	--disable-nls			\
	--disable-threads		\
	--disable-multilib		\
	--disable-libstdcxx-pch		\
	--disable-libstdcxx-verbose	\
	--disable-libstdcxx-debug	\
	--disable-hosted-libstdcxx	\
	--disable-libssp \
	--disable-libquadmath \
	--disable-libgomp \
	--disable-libatomic \
	--disable-libsanitizer \
	--disable-libvtv \
	--with-newlib			\
	--disable-libgcov	\
	--disable-bootstrap		\
	--with-gmp=/opt/local/		\
	--without-headers || exit 1
fi

# 	--with-libiconv-prefix="${iconv}" \

if [ "$7" == "gcc-stage-2"]; then
gmake -j${concurrency} all-gcc

if [ "$4" == "copy-dance" ]; then
cp ~/Documents/Programming/kernel/fake-libbacktrace/libbacktrace.a ~/cc_src/build/gcc-14.1.0/libbacktrace/.libs
gmake -j${concurrency} all-gcc || exit 1
fi
fi

echo ""
echo ""
echo "======== FINISH MAKE GCC ========"
echo ""
echo ""

# note: for this step to work, must go into build/gcc-version/gcc/ada/gcc-interface/Makefile and append -liconv to a bunch of lines starting with $(GNATLINK), $(GNATMAKE). 
# I'm not sure whih lines make it work, but with this file on 14.1.0 the lines were all between 468-503

#gmake -j${concurrency} all-target-libgcc || exit 1
gmake -j${concurrency} -C gcc cross-gnattools ada.all.cross \
    || exit 1

#LDFLAGS="-L/opt/homebrew/Cellar/libiconv/1.18/lib" \
#CPPFLAGS="-I/opt/homebrew/Cellar/libiconv/1.18/include" \


echo ""
echo ""
echo "======== FINISH MAKE GNAT ========" 
echo ""
echo ""

#gmake -j${concurrency} install-strip-gcc install-target-libgcc || exit 1
gmake -j${concurrency} install-strip-gcc || exit 1

echo ""
echo ""
echo "======== SUCCESS ========"
echo ""
echo ""