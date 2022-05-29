FROM quay.io/centos/centos:stream9 AS build-stage

RUN dnf update -y && dnf info virtio-win && mkdir -p /output
WORKDIR /output
# hadolint ignore=DL3041
RUN dnf install -y cpio \
    && dnf install -y --downloadonly --downloaddir=/output virtio-win \ 
    && dnf clean all
RUN bash -c 'rpm2cpio /output/virtio-win-*.rpm | cpio -idmv'

FROM scratch AS export-stage
COPY --from=build-stage /output/usr/share/virtio-win/virtio-win.iso /
