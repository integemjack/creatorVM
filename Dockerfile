# Built with arch: amd64 flavor: lxde image: ubuntu:20.04
#
################################################################################
# base system
################################################################################

FROM kasmweb/desktop:1.12.0 as system

RUN lsb_release -a

ENV DEBIAN_FRONTEND=noninteractive

RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add

RUN sudo apt-get update
RUN sudo apt-get upgrade -y
RUN sudo apt-get install git curl wget -y
# RUN apt-get install libasound2 -y

# RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# RUN wget https://github.com/integemjack/Integem_Creator/releases/download/v1.3.601/integem-creator_1.3.601_amd64_tools.deb && dpkg -i integem-creator_1.3.601_amd64_tools.deb
# RUN curl -LO https://github.com/integemjack/Integem_Creator/releases/download/v1.3.601/integem-creator_1.3.601_amd64_tools.deb \
#     && (dpkg -i ./integem-creator_1.3.601_amd64_tools.deb || apt-get install -fy)
# built-in packages

# install firefox
# RUN curl -LO http://kr.archive.ubuntu.com/ubuntu/pool/main/s/systemd/libudev1_249.11-0ubuntu3_amd64.deb
# RUN dpkg -i libudev1_249.11-0ubuntu3_amd64.deb

# RUN add-apt-repository ppa:ubuntu-mozilla-security/ppa
# RUN apt update
# RUN apt install firefox -y

# RUN apt update \
#     && apt install -y gpg-agent \
#     && curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
#     && (dpkg -i ./google-chrome-stable_current_amd64.deb || apt-get install -fy) \
#     && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add \
#     && rm google-chrome-stable_current_amd64.deb \
#     && rm -rf /var/lib/apt/lists/*

# RUN apt update \
#     && apt install -y --no-install-recommends --allow-unauthenticated \
#     lxde gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
#     && apt autoclean -y \
#     && apt autoremove -y \
#     && rm -rf /var/lib/apt/lists/*


# Additional packages require ~600MB
# libreoffice  pinta language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw


# nodejs
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
#     && apt-get install -y nodejs

# RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
#     && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
#     && apt update && apt install yarn -y

# vscode
RUN mkdir -p /root/Desktop && cd /root/Desktop && wget https://az764295.vo.msecnd.net/stable/e4503b30fc78200f846c62cf8091b76ff5547662/code_1.70.2-1660629410_amd64.deb && mv code*.deb code.deb
# COPY code_1.69.0-1657183742_amd64.deb /root/Desktop/code_1.69.0-1657183742_amd64.deb
RUN (dpkg -i /root/Desktop/code.deb || apt-get install -fy)

# libfuse.so.2
# RUN wget https://github.com/libfuse/libfuse/archive/refs/tags/fuse-3.11.0.tar.gz
# RUN tar zxvf fuse-3.11.0.tar.gz
# RUN cd libfuse-fuse-3.11.0 && ./configure && make && make install

################################################################################
# builder
################################################################################
FROM node:14 as builder

# RUN apt update
# RUN apt install software-properties-common -y
# RUN add-apt-repository ppa:longsleep/golang-backports
# RUN apt update
# RUN apt install golang-go git -y
WORKDIR /src

RUN git clone http://jackwang:jackwang@99.109.54.153:8821/jackwang/Integem_Creator.git .
RUN git checkout -- . && git pull
RUN npm i
RUN npm run build
RUN ls -alF




################################################################################
# merge
################################################################################
FROM system
LABEL maintainer="jack.wang@integem.com"


COPY --from=builder /src/build/iCreator*.AppImage /root/iCreator.AppImage

# COPY iCreator-1.3.601.AppImage /root/
RUN chmod +x /root/iCreator.AppImage
RUN cd /root && ./iCreator.AppImage --appimage-extract
# RUN mkdir -p /home/integem/Desktop
RUN mv /root/squashfs-root /root/iCreator
COPY integem-creator.desktop /root/Desktop/integem-creator.desktop

RUN echo "alias code='/usr/share/code/code . --no-sandbox --unity-launch'" >> /root/.bashrc

RUN rm -rf /root/iCreator-1.3.601.AppImage
RUN rm -rf /root/Desktop/code*
RUN mkdir -p /root/Downloads

# RUN /root/iCreator/integem-creator --no-sandbox &

# RUN modprobe snd-aloop index=2
# EXPOSE 80
# WORKDIR /root
# ENV HOME=/home/ubuntu \
#     SHELL=/bin/bash
# HEALTHCHECK --interval=30s --timeout=5s CMD curl --fail http://127.0.0.1:6079/api/health
# ENTRYPOINT ["/startup.sh"]
# ENTRYPOINT ["/root/iCreator/integem-creator","--no-sandbox"]
