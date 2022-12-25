FROM ubuntu:22.04 AS build-stage
ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update -y \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install --no-install-recommends -y ovmf \
    && rm -rf /var/lib/apt/lists/*

FROM scratch AS export-stage
COPY --from=build-stage /usr/share/OVMF/OVMF_CODE.ms.fd /
COPY --from=build-stage /usr/share/OVMF/OVMF_VARS.ms.fd /
COPY --from=build-stage /usr/share/OVMF/OVMF_CODE_4M.ms.fd /
COPY --from=build-stage /usr/share/OVMF/OVMF_VARS_4M.ms.fd /
