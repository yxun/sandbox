FROM quay.io/centos/centos:stream8

ADD scripts/maistra_builder.env /root/maistra_builder.env
ADD scripts/maistra_install_deps.sh /root/maistra_install_deps.sh
RUN chmod +x /root/maistra_install_deps.sh

WORKDIR /root
RUN ./maistra_install_deps.sh

ADD scripts/prow-entrypoint-main.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
# Run config setup in local environments
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]