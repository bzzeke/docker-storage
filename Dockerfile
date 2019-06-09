FROM ubuntu:18.04

ARG STORAGE_UID
ARG STORAGE_GID
ARG STORAGE_USER
ARG STORAGE_PASSWORD

ADD packages /tmp
RUN apt-get update \

    # Upgrade
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \

    # Install dependencies
    && apt-get install supervisor wget avahi-daemon cracklib-runtime db-util db5.3-util libtdb1 libavahi-client3 libcrack2 libcups2 libpam-cracklib libdbus-glib-1-2 libevent-2.1-6 libldap-2.4-2 libwrap0 -y \

    # Download & Install Yandex.Disk
    && cd /tmp \
    && wget https://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb \
    && dpkg -i yandex-disk_latest_amd64.deb \
    && dpkg -i netatalk_3.1.12-1_amd64.deb \
    && apt-get install -f -y \

    # Cleanup
    && rm *.deb \
    && apt-get purge -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y \


    && mkdir /srv/Yandex.Disk \
    && chown ${STORAGE_UID}:${STORAGE_GID} /srv/Yandex.Disk

RUN groupadd -g${STORAGE_GID} ${STORAGE_USER}
RUN useradd -u${STORAGE_UID} -g${STORAGE_GID} ${STORAGE_USER}
RUN mkdir -p /home/${STORAGE_USER}
RUN echo "${STORAGE_USER}:${STORAGE_PASSWORD}" | chpasswd
RUN mkdir -p /home/${STORAGE_USER}/.config/yandex-disk
RUN chown -R ${STORAGE_UID}:${STORAGE_GID} /home/${STORAGE_USER}
RUN cp -r /usr/local/lib/* /usr/lib/

ADD config /

CMD supervisord -n
