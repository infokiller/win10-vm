#!/usr/bin/env bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -o errexit -o errtrace -o nounset -o pipefail

readonly DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

_print_error() {
  local error normal
  # Red color
  error="$(tput setaf 1 2> /dev/null)" || true
  normal="$(tput sgr0 2> /dev/null)" || true
  printf >&2 '%s\n' "${error}${*}${normal}"
}

get_virtio_drivers() {
  (
    # shellcheck disable=SC2030
    export DOCKER_BUILDKIT=1
    cd virtio &&
      docker build -f Dockerfile -t rhel-virtio --output out .
  )
}

get_ovmf_files() {
  (
    # shellcheck disable=SC2031
    export DOCKER_BUILDKIT=1
    cd ovmf && docker build -f Dockerfile -t ubuntu-ovmf --output out .
  )
}

main() {
  cd -- "${DIR}"
  get_virtio_drivers
  get_ovmf_files
}

main "$@"
