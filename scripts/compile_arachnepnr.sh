# -- Compile Arachne PnR script

ARACHNE=arachne-pnr
GIT_ARACHNE=https://github.com/cseed/arachne-pnr.git

# -- Setup
. $WORK_DIR/scripts/build_setup.sh

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ARACHNE || git clone --depth=1 $GIT_ARACHNE $ARACHNE
git -C $ARACHNE pull

# -- Copy the upstream sources into the build directory
rsync -a $ARACHNE $BUILD_DIR --exclude .git

cd $BUILD_DIR/$ARACHNE

# -- Compile it
if [ $ARCH == "darwin" ]; then
  make -j$J CXX="$CXX" LIBS="-lm" ICEBOX="../icestorm/icebox"
else
  sed -i "s/bin\/arachne-pnr\ -d\ /\.\/bin\/arachne-pnr\ -d\ /;" Makefile
  make -j$J CXX="$CXX" LIBS="-static -static-libstdc++ -static-libgcc -lm" ICEBOX="../icestorm/icebox"
fi

if [ $ARCH != "darwin" ]; then
  # -- Test the generated executables
  test_bin bin/arachne-pnr
  test -e share/$ARACHNE/chipdb-1k.bin || exit 1
  test -e share/$ARACHNE/chipdb-8k.bin || exit 1
fi

# -- Copy the executable to the bin dir
cp bin/arachne-pnr $PACKAGE_DIR/$NAME/bin/arachne-pnr$EXE

# -- Copy the chipdb*.bin data files
if [ ${ARCH:0:7} == "windows" ]; then
  cp -r share/$ARACHNE/chipdb*.bin $PACKAGE_DIR/$NAME/bin
else
  mkdir -p $PACKAGE_DIR/$NAME/share/$ARACHNE
  cp -r share/$ARACHNE/chipdb*.bin $PACKAGE_DIR/$NAME/share/$ARACHNE
fi
