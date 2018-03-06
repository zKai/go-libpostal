FROM alpine as libpostal

ENV BUILD_PACKAGES build-base curl autoconf automake libtool git
ENV BUILD_OUT /app

RUN apk add --no-cache --virtual build-deps ${BUILD_PACKAGES} \
    && git clone https://github.com/openvenues/libpostal \
    && cd libpostal \
    && sed -i 's/ -P $NUM_WORKERS//' src/libpostal_data \
    && ./bootstrap.sh \
    && ./configure --datadir=${BUILD_OUT} \
    && make \
    && make install DESTDIR=${BUILD_OUT} \
    && apk del build-deps

FROM golang:alpine

ENV APP /app
ENV PKG_CONFIG_PATH ${APP}/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH ${APP}/usr/local/lib:$LD_LIBRARY_PATH

COPY --from=libpostal /app/ /app/

RUN sed -i 's#prefix=/usr/local#prefix=/app/usr/local#' ${APP}/usr/local/lib/pkgconfig/libpostal.pc

RUN apk add --no-cache --virtual build-deps git pkgconfig build-base
