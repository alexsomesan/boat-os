#!/bin/sh

mkdir -p /tmp/build
cd /tmp/build

git clone --depth 1 https://github.com/stripydog/kplex.git
cd kplex
make && make install
cd ..

git clone --depth 1 https://gitea.osmocom.org/sdr/rtl-sdr.git
cd rtl-sdr
mkdir _build && cd _build
cmake ../ -Wno-dev -DDETACH_KERNEL_DRIVER=ON -DINSTALL_UDEV_RULES=ON
make install
ldconfig
cd ..

git clone --depth 1 https://github.com/dgiardini/rtl-ais.git
cd rtl-ais
make && cp rtl_ais /usr/local/bin/
cd ..

git clone --depth 1 https://github.com/canboat/canboat.git
# cd canboat
# make install
# cd ..
