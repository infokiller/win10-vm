FROM ubuntu:latest AS build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y ovmf

FROM scratch AS export-stage
COPY --from=build /usr/share/OVMF/OVMF_CODE.ms.fd /usr/share/OVMF/OVMF_VARS.ms.fd /
