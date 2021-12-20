FROM archlinux

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm reflector
RUN reflector --verbose --protocol "https,http,ftp" --latest 50 --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -S --noconfirm base-devel pacman-contrib git sudo

RUN sed -i -e 's/.*MAKEFLAGS.*/MAKEFLAGS=$(($(nproc)+1))/g' /etc/makepkg.conf
RUN sed -i -e 's/-O[s0123]/-O3/g' /etc/makepkg.conf

RUN useradd -m builduser
RUN echo 'builduser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builduser

RUN cd /home/builduser && \
    su -c 'git clone https://aur.archlinux.org/yay-bin.git' builduser && \
    cd yay-bin && \
    su -c 'makepkg -sri --noconfirm' builduser && \
    cd .. && rm -rf yay

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
