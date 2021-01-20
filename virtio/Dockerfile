FROM registry.access.redhat.com/ubi8/ubi AS build

ARG RHEL_USERNAME
ARG RHEL_PASSWORD

RUN subscription-manager register --auto-attach \
    --username "${RHEL_USERNAME}" --password "${RHEL_PASSWORD}"
RUN dnf update -y
RUN mkdir -p /output
WORKDIR /output
RUN dnf download -y virtio-win

FROM scratch AS export-stage
COPY --from=build /output /
