FROM debian:buster
LABEL maintainer='František Dvořák <valtri@civ.zcu.cz>'

ENV ADMIN_USER 'admin/admin'
ENV ADMIN_KEY ''
ENV DESTDIR '/keytabs'
ENV DOMAIN_REALM 'EXAMPLE.COM'
ENV KDC_HOSTNAME ''
ENV MASTER_KEY ''
ENV REALM 'EXAMPLE.COM'
ENV PRINCIPALS ''

EXPOSE 88 464 749

RUN apt-get update \
 && apt-get install -y --no-install-recommends krb5-admin-server krb5-kdc \
 && rm -rf /var/lib/apt/lists/* \
 && touch /.docker-first-launch

COPY docker-entry.sh /
CMD /docker-entry.sh /bin/bash -l
