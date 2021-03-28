FROM ubuntu:latest AS build-stage
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y ovmf

FROM scratch AS export-stage
COPY --from=build-stage /usr/share/OVMF/OVMF_CODE.ms.fd /
COPY --from=build-stage /usr/share/OVMF/OVMF_VARS.ms.fd /
