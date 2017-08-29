#!/bin/sh


pc(){

./configure --prefix=$HOME/work/py362 --enable-optimizations


make 

[  "$1"x = "test" ] && make test

make atlinstall

}


cross(){


#export PATH=/home/pengdonglin/src/qemu/aarch64/gcc-linaro-aarch64-linux-gnu-4.9-2014.07_linux/bin:$PATH

../Python-3.6.0/configure \
    --host=aarch64-linux-gnu \
    --build=aarch64 \
    --prefix="$1" \
    --enable-ipv6 \
    --enable-shared \
    ac_cv_file__dev_ptmx="yes" \
    ac_cv_file__dev_ptc="no" \
    LDFLAGS="-L/home/pengdonglin/src/qemu/python_cross_compile/SQlite/aarch64/lib" \
    CPPFLAGS="-I/home/pengdonglin/src/qemu/python_cross_compile/SQlite/aarch64/include"



}


