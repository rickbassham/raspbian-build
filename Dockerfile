FROM debian:buster

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=America/New_York

RUN apt-get update \
    && apt-get install -y apt-utils \
    && dpkg-reconfigure apt-utils \
    && apt-get install -y \
    qemu-user-static debootstrap \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /raspbian
RUN debootstrap --no-check-gpg --foreign --arch=armhf buster /raspbian https://archive.raspbian.org/raspbian
RUN cp /usr/bin/qemu-arm-static /raspbian/usr/bin
RUN chroot /raspbian qemu-arm-static /bin/bash -c '/debootstrap/debootstrap --second-stage'

RUN chroot /raspbian qemu-arm-static /bin/bash -c 'echo "deb https://archive.raspbian.org/raspbian buster main contrib non-free rpi" > /etc/apt/sources.list'
RUN chroot /raspbian qemu-arm-static /bin/bash -c 'apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*'
RUN chroot /raspbian qemu-arm-static /bin/bash -c 'apt-get update && apt-get install -y build-essential devscripts debhelper fakeroot cdbs software-properties-common cmake wget apt-transport-https ca-certificates && rm -rf /var/lib/apt/lists/*'

RUN echo "nameserver 8.8.8.8" > /raspbian/etc/resolv.conf

ENTRYPOINT [ "chroot", "/raspbian", "qemu-arm-static" ]
CMD ["/bin/bash"]
