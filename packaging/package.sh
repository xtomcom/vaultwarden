#!/usr/bin/env bash
# Build release archives and .deb packages.
#
# Usage: package.sh <version> <input-dir> <output-dir>
#
# <input-dir> must contain:
#   bin-{amd64,arm64}-{gnu,musl}/vaultwarden
#   web-vault.tar.gz   (tarball with a top-level web-vault/ directory)
#   LICENSE.txt
set -euo pipefail

if [ $# -ne 3 ]; then
    echo "Usage: $0 <version> <input-dir> <output-dir>" >&2
    exit 1
fi

version="$1"
input="$(realpath "$2")"
mkdir -p "$3"
output="$(realpath "$3")"
packaging="$(cd "$(dirname "$0")" && pwd)"

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

tar -C "${work}" -xzf "${input}/web-vault.tar.gz"

for arch in amd64 arm64; do
    for libc in gnu musl; do
        name="vaultwarden-${version}-linux-${arch}-${libc}"
        stage="${work}/${name}"
        mkdir -p "${stage}"

        install -m 0755 "${input}/bin-${arch}-${libc}/vaultwarden" "${stage}/vaultwarden"
        cp -a "${work}/web-vault" "${stage}/web-vault"
        install -m 0644 \
            "${packaging}/vaultwarden.service" \
            "${packaging}/vaultwarden.env" \
            "${input}/LICENSE.txt" \
            "${stage}/"

        tar -C "${work}" --owner=0 --group=0 --numeric-owner -czf "${output}/${name}.tar.gz" "${name}"

        if [ "${libc}" = "musl" ]; then
            # nfpm does not expand variables in file paths, so build from a fixed layout
            pkg="${work}/pkg-${arch}"
            mkdir -p "${pkg}"
            cp -a "${stage}" "${pkg}/root"
            cp -a "${packaging}/scripts" "${pkg}/scripts"
            for packager in deb rpm; do
                (cd "${pkg}" && VERSION="${version}" ARCH="${arch}" \
                    nfpm package --config "${packaging}/nfpm.yaml" --packager "${packager}" --target "${output}/")
            done
        fi
    done
done

(cd "${output}" && sha256sum -- *.tar.gz *.deb *.rpm > SHA256SUMS)
