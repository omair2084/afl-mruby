#!/bin/bash
export TERM=xterm-color

#cp -f /mruby/bin/mruby /results/mruby

echo "Starting MRuby fuzzing with $(nproc) cores/fuzzers"

SLAVE_COUNT=$(expr $(nproc) - 1)
export TESTCASE_DIR=testcases
export AFL_OUT_DIR=results

# Start master and slaves in background and hide any output.
echo "Starting master-fuzzer"
gnome-terminal -- afl-fuzz -i $TESTCASE_DIR -o $AFL_OUT_DIR -t 10000 -m none -Mmaster-0 -- mruby/bin/mruby @@
for i in $(seq 1 $SLAVE_COUNT); do
    echo "Starting slave $i"
    gnome-terminal -- afl-fuzz -i $TESTCASE_DIR -o $AFL_OUT_DIR -t 10000 -m none -Sslave-$i -- mruby/bin/mruby @@
    sleep 1
done
