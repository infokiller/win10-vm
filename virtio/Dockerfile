FROM centos:8 AS build-stage

RUN dnf update -y
RUN mkdir -p /output
WORKDIR /output
RUN dnf install -y --downloadonly --downloaddir=/output virtio-win \ 
    && dnf clean all
RUN bash -c 'rpm2cpio /output/virtio-win-*.rpm | cpio -idmv'

FROM scratch AS export-stage
COPY --from=build-stage /output/usr/share/virtio-win/virtio-win.iso /
