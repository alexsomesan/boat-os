#!/bin/sh

mkdir -p /tmp/build
cd /tmp/build

wget -O kplex.zip https://github.com/stripydog/kplex/archive/master.zip
unzip kplex.zip
cd kplex-master
make && make install
cd ..

wget -O rtl-sdr.zip https://github.com/osmocom/rtl-sdr/archive/master.zip
unzip rtl-sdr.zip
cd rtl-sdr-master
mkdir _build && cd _build
cmake ../ -Wno-dev -DDETACH_KERNEL_DRIVER=ON -DINSTALL_UDEV_RULES=ON
make install
ldconfig
cd ..

wget -O rtl-ais.zip https://github.com/dgiardini/rtl-ais/archive/master.zip
unzip rtl-ais.zip
cd rtl-ais-master
make && cp rtl_ais /usr/local/bin/
cd ..
