#!/bin/bash
unset LD_LIBRARY_PATH

STARTDIR=$PWD
echo $STARTDIR

if [ ! -f $STARTDIR/toolchain/x-tools/arm-frosted-eabi/bin/arm-frosted-eabi-gcc ]; then
    pushd $STARTDIR/toolchain
        rm -f $STARTDIR/env.frosted
        mkdir -p $STARTDIR/toolchain/local

        pushd stlink
            ./autogen.sh && ./configure --prefix=$STARTDIR/toolchain/local && make install
            if [ $? -eq 0 ]; then
                echo ""
                echo "** STLINK BUILD SUCCESSFUL! **"
                echo ""
                echo "export PATH=\$PATH:$STARTDIR/toolchain/local/bin" >> $STARTDIR/env.frosted
            else
                exit 1
            fi
        popd

        patch -p0 < $STARTDIR/toolchain/ctng-custom-elf2flt.patch
        pushd crosstool-ng
            autoreconf -i -f
            ./configure --prefix=$STARTDIR/toolchain/local && make install
            if [ $? -ne 0 ]; then
                exit 1
            fi
        popd
        mkdir -p $STARTDIR/toolchain/tarballs
        cat arm-frosted-eabi.config.in | sed -e "s#__CURRENT_DIR__#$STARTDIR/toolchain#g" > .config

        $STARTDIR/toolchain/local/bin/ct-ng build
        if [ $? -eq 0 ]; then
            echo ""
            echo "** TOOLCHAIN BUILD SUCCESSFUL! **"
            echo ""
            echo "export PATH=\$PATH:$STARTDIR/toolchain/x-tools/arm-frosted-eabi/bin" >> $STARTDIR/env.frosted
            echo "export PS1=\"\${PS1}frosted> \"" >> $STARTDIR/env.frosted
        else
            exit 1
        fi
    popd
else
    echo "the frosted toolchain appears to have already been built"
fi

echo ""
echo "to use the frosted toolchain, source the '$STARTDIR/env.frosted' file"
