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



