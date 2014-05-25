#!/bin/bash

# export USE_CCACHE=1;
# export CCACHE_DIR=.ccache;
# ccache -M 2G;

# Add toolchain to path & allow caching from CodeBench (much faster than ccache!).
export PATH=$HOME/gcc/scb_arm-eabi-2014.05/bin/cache:$HOME/gcc/scb_arm-eabi-2014.05/bin:$PATH

# For CodeBench caching, arm-none-*eabi- must be called explicitly from $PATH.
export CROSS_COMPILE=arm-none-linux-gnueabi-

export ARCH=arm;

while getopts ":c :p" opt
do
case "$opt" in
        c)
             CLEAN=true;;
        p)
             PACKAGE=true;;
        *)
             break;;
    esac
done

if [ "$CLEAN" = "true" ]; then
    echo "Making clean..."
    make clean
    echo "Removing build log..."
    rm -rf build.log
    echo "Cleaning package dir..."
    rm -rf out
else
    make flo_defconfig;

    time logsave build.log make -j4;

    if [ "$PACKAGE" = "true" ]; then
        echo ""
        if [ -e arch/arm/boot/zImage ]; then
            echo "Copying packaging components..."
#           mkdir -p out/system/lib/modules/
#           cp -a $(find . -name *.ko -print) out/system/lib/modules/
            mkdir out
            cp -R package/* out/
            cp arch/arm/boot/zImage out/kernel/
            echo "Packaging..."
            cd out
            cdate=`date "+%Y-%m-%d"`
            zfile=BoxCar-kernel-flo-$cdate.zip
            zip -r $zfile .
            cd ..
            echo " ZIPFILE: out/$zfile"
        else
            echo "Something went wrong. zImage not found."
        fi
    fi
fi
