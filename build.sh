#!/bin/bash

#set -e

KERNEL_DEFCONFIG=cepheus_defconfig
ANYKERNEL3_DIR=$PWD/AnyKernel3/
FINAL_KERNEL_ZIP=Asuna_cepheus_DLN.zip

# paths
TC="$PWD"
#注意 你需要下载17.0.2版本的clang并自行加入环境变量
#Attention! You should download ver17.0.2 clang for compiling.
# Download Url: https://github.com/llvm/llvm-project/releases/tag/llvmorg-17.0.2
# PATH=${TC}/clang+llvm-17.0.2-x86_64-linux-gnu-ubuntu-22.04/bin:${TC}/aarch64/bin:${TC}/arm/bin:$PATH

export LLVM=1
export KBUILD_OUTPUT=$PWD/out
export CC=clang
#请按照需求修改下方指令并解除注释
#Edit the code below according to what you need,its up to U!
#export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
export USE_CCACHE=1

# Speed up build process
MAKE="./makeparallel"

make O=out ARCH=arm64 cepheus_defconfig

START=$(date +"%s")

make ARCH=arm64 \
        O=out \
        CC=clang \
	AR=llvm-ar \
        LD=ld.lld \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        -j$(nproc --all)
               

echo -e "$yellow**** Verify Image.gz-dtb ****$nocol"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb
mkdir -p $PWD/kernel_out
cp cepheus_anykernel.sh $ANYKERNEL3_DIR/anykernel.sh

echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR
echo -e "$yellow**** Removing leftovers ****$nocol"
#rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
#rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Copying Image.gz-dtb ****$nocol"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/

echo -e "$yellow**** Time to zip up! ****$nocol"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP $PWD/kernel_out/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Done, here is your checksum ****$nocol"
cd ..
#rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
#rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
#rm -rf out/

END=$(date +"%s")
DIFF=$((END - START))
echo -e '\033[01;32m' "Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds" || exit
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
