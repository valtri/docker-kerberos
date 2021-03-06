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

EXPOSE 88/tcp 464/tcp 749/tcp
EXPOSE 88/udp 464/udp 750/udp

RUN apt-get update \
 && apt-get install -y --no-install-recommends krb5-admin-server krb5-kdc \
 && rm -rf /var/lib/apt/lists/* \
 && touch /.docker-first-launch

COPY docker-entry.sh /
ENTRYPOINT ["/docker-entry.sh"]
HEALTHCHECK --interval=10s --start-period=30s --retries=3 \
  CMD service krb5-kdc status && service krb5-admin-server status || exit 1
