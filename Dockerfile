FROM ubuntu:22.04

LABEL org.opencontainers.image.authors="Renato Freitas <renato.freitas@pullup.com.br>"
LABEL org.opencontainers.image.description="TI Code Composer Studio 20.2.0"
LABEL org.opencontainers.image.version="20.2.0.00012"

ARG CCS_URL="https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-J1VdearkvK/"
ENV MAJOR_VER=20 \
    MINOR_VER=2 \
    PATCH_VER=0 \
    BUILD_VER=00012 \
    COMPONENTS=PF_MSP430 \
    PATH="/opt/ti/ccs/eclipse:$PATH" \
    CCS_EXE="/opt/ti/ccs/eclipse/ccs-server-cli.sh"

# INSTALL DEPENDENCIES
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libc6:i386 \
        libgconf-2-4:i386 \
        libncurses5:i386 \
        libtinfo5:i386 \
        libusb-0.1-4:i386 \
        libpython3.10 \
        build-essential \
        ca-certificates \
        unzip \
        curl \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# INSTALL CCS
RUN mkdir -p /ccs_install /opt/ti /etc/udev/rules.d /etc/init.d && \
    # Mock udev to avoid ccs install error 
    printf '#!/bin/sh\nexit 0' > /etc/init.d/udev && \
    chmod +x /etc/init.d/udev && \
    # Download CCS
    echo "Downloading CCS..." && \
    wget --no-check-certificate -O /ccs_install/ccs.zip \
    "${CCS_URL}${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}/CCS_${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}.${BUILD_VER}_linux.zip" && \
    echo "Extracting..." && \
    unzip -q /ccs_install/ccs.zip -d /ccs_install && \
    # Find the installer dir (sometimes names vary slightly, using wildcard helps)
    INSTALLER_DIR=$(find /ccs_install -maxdepth 1 -type d -name "CCS_*_linux") && \
    # Install
    echo "Installing..." && \
    chmod +x "$INSTALLER_DIR/ccs_setup_${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}.${BUILD_VER}.run" && \
    "$INSTALLER_DIR/ccs_setup_${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}.${BUILD_VER}.run" \
        --mode unattended \
        --enable-components ${COMPONENTS} \
        --prefix /opt/ti && \
    echo "Cleaning up..." && \
    rm -rf /ccs_install /tmp/*


RUN echo "CCS Install Complete. Version: ${MAJOR_VER}.${MINOR_VER}.${PATCH_VER}"
