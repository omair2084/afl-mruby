#!/bin/bash

if [ `whoami` != root ]; then
    echo "The script requires sudo/root!"
    exit
fi

read -p "Enable AddressSanitizer (y/n)? " USE_ASAN
case "$USE_ASAN" in
  y|Y ) sed -i 's/#.*conf.cc.flags/conf.cc.flags/g' build_config.rb;sed -i 's/#.*conf.linker.flags/conf.linker.flags/g' build_config.rb;;
  n|N ) sed -i 's/conf.cc.flags/#conf.cc.flags/g' build_config.rb;sed -i 's/conf.linker.flags/#conf.linker.flags/g' build_config.rb;;
  * ) echo "Invalid choice."; exit;;
esac

read -p "Fuzz or triage (afl/gcc)? " USE_AFL
case "$USE_AFL" in
  afl|Afl|AFL ) sed -i 's/toolchain :gcc$/toolchain :afl/g' build_config.rb;;
  gcc|Gcc|GCC ) sed -i 's/toolchain :afl$/toolchain :gcc/g' build_config.rb;;
  * ) echo "Invalid choice, write \"afl\" if you want to fuzz or write \"gcc\" if you only want to compile mruby.";exit;;
esac

export AFL_URL=http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
export MRUBY_URL=https://github.com/mruby/mruby.git

# Get required build dependencies.
apt-get update && apt-get -y install \
        wget \
        git \
        ca-certificates \
        build-essential \
        ruby \
        libc6-dev \
        bison \
        libssl-dev \
        libhiredis-dev \
        llvm clang \
        nano gdb strace golang python-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

# Get latest version AFL-Fuzzer and install with llvm_mode.
cd /tmp
wget $AFL_URL --no-verbose \
    && mkdir afl-src \
    && tar -xzf afl-latest.tgz -C afl-src --strip-components=1 \
    && cd afl-src \
    && make \
    && cd llvm_mode && make && cd .. \
    && make install \
    && rm -rf /tmp/afl-latest.tgz /tmp/afl-src

# Get latest MRuby from Github trunk.
git clone $MRUBY_URL

# Add AFL-related build config and replace mruby-bin code with persistent fuzzer stub.
mv build_config.rb mruby/build_config.rb
mv stub.c mruby/mrbgems/mruby-bin-mruby/tools/mruby/mruby.c
AFL_HARDEN=1 ASAN_OPTIONS=detect_leaks=0 mruby/mrbgems/mruby-bin-mruby/tools/mruby/minirake

#Create folders
mkdir testcases
mkdir results

echo core>/proc/sys/kernel/core_pattern
