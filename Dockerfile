FROM ubuntu:16.04 as builder

RUN groupadd -g 1000 docker && useradd docker -u 1000 -g 1000 -s /bin/bash --no-create-home
RUN mkdir /build && chown docker:docker /build

RUN apt-get update && apt-get install -y \
  make unrar-free autoconf automake libtool gcc g++ gperf \
  flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python-serial \
  sed git unzip bash help2man wget bzip2 libtool-bin

RUN su docker -c " \
    git clone --recursive https://github.com/pfalcon/esp-open-sdk.git /build/esp-open-sdk ; \
    cd /build/esp-open-sdk ; \
    make STANDALONE=n ; \
"

FROM ubuntu:16.04
RUN apt-get update && apt-get install -y make python-dev python-pip git python-serial && pip install pyqrcode pypng
COPY --from=builder /build/esp-open-sdk/xtensa-lx106-elf /opt/xtensa-lx106-elf
RUN git clone --recursive https://github.com/Superhouse/esp-open-rtos.git /esp-open-rtos
RUN git clone https://github.com/raburton/esptool2.git /esptool2 && cd /esptool2 && make && cp /esptool2/esptool2 /usr/local/bin/esptool2
ENV SDK_PATH=/esp-open-rtos
ENV PATH /opt/xtensa-lx106-elf/bin:$PATH
ADD . /sonoff-s20-homekit
WORKDIR /sonoff-s20-homekit