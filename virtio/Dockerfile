FROM centos:latest AS build

RUN dnf update -y
RUN mkdir -p /output
WORKDIR /output
RUN dnf install -y --downloadonly --downloaddir=/output virtio-win
RUN bash -c 'rpm2cpio /output/virtio-win-*.rpm | cpio -idmv'

FROM scratch AS export-stage
COPY --from=build /output/usr/share/virtio-win/virtio-win.iso /
