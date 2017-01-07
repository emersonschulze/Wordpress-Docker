## BUILDING
##   (from project root directory)
##   $ docker build -t ubuntu-for-emersonschulze-Wordpres-Docker .
##
## RUNNING
##   $ docker run ubuntu-for-emersonschulze-Wordpres-Docker

FROM gcr.io/stacksmith-images/minideb:jessie-r8

MAINTAINER EmersonSchulze <emerson7e@gmail.com>

ENV STACKSMITH_STACK_ID="nd6ziiq" \
    STACKSMITH_STACK_NAME="Ubuntu for emersonschulze/Wordpress-Docker" \
    STACKSMITH_STACK_PRIVATE="1"

## STACKSMITH-END: Modifications below this line will be unchanged when regenerating


ENV EMERSONSCHULZE_IMAGE_VERSION=10.1.20-r1 \
    EMERSONSCHULZE_APP_NAME=emersondb \
    EMERSONSCHULZE_APP_USER=mysql

# System packages required
RUN install_packages libc6 libaio1 zlib1g libjemalloc1 libssl1.0.0 libstdc++6 libgcc1 libncurses5 libtinfo5

# Install emersondb
RUN bitnami-pkg unpack emersondb-10.1.20-0 --checksum 7409ba139885bc4f463233a250806f557ee41472e2c88213e82c21f4d97a77d7

ENV PATH=/opt/emersonschulze/$EMERSONSCHULZE_APP_NAME/sbin:/opt/emersonschulze/$EMERSONSCHULZE_APP_NAME/bin:$PATH

COPY rootfs /

VOLUME ["/emersonschulze/$EMERSONSCHULZE_APP_NAME"]

EXPOSE 3306

ENTRYPOINT ["/app-entrypoint.sh"]

CMD ["nami", "start", "--foreground", "emersondb"]
