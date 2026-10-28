# vaultwarden builds

Linux binaries and .deb packages of [dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden), extracted unchanged from the official images at [ghcr.io/dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden/pkgs/container/vaultwarden).

`.github/workflows/release.yml` runs daily:

1. Reads the latest release from GitHub and the latest version tag from ghcr.io.
2. If we have no release for that version yet, waits until `ghcr.io/dani-garcia/vaultwarden:<ver>` and `:<ver>-alpine` are published for both `linux/amd64` and `linux/arm64` (otherwise the next run retries).
3. Pulls each image by digest on a native runner (`ubuntu-latest` / `ubuntu-24.04-arm`), copies out `/vaultwarden` and `/web-vault`, and checks `--version`.
4. Packages archives, .deb and .rpm files with nfpm.
5. Commits `release.json` (version, timestamp, image digests) and publishes a GitHub release tagged on that commit. Backfilling an older version leaves `release.json` untouched.

| Asset | Source image | Runs on |
|---|---|---|
| `vaultwarden-<ver>-linux-{amd64,arm64}-gnu.tar.gz` | `ghcr.io/dani-garcia/vaultwarden:<ver>` (Debian trixie) | glibc >= 2.39 (Ubuntu 24.04+ / Debian 13+), needs libssl3, libpq5, libmariadb3 |
| `vaultwarden-<ver>-linux-{amd64,arm64}-musl.tar.gz` | `ghcr.io/dani-garcia/vaultwarden:<ver>-alpine` | Any Linux (static) |
| `vaultwarden_<ver>-1_{amd64,arm64}.deb` | Alpine image (static musl) | Debian / Ubuntu |
| `vaultwarden-<ver>-1.{x86_64,aarch64}.rpm` | Alpine image (static musl) | RHEL / Alma / Rocky / Fedora / openSUSE |

Every archive contains the binary, the `web-vault` front end, a systemd unit and an env file.

## .deb / .rpm layout

| Path | |
|---|---|
| `/usr/bin/vaultwarden` | binary |
| `/usr/share/vaultwarden/web-vault/` | web front end |
| `/etc/vaultwarden/vaultwarden.env` | config (kept on upgrade) |
| `/var/lib/vaultwarden/` | data |
| `/usr/lib/systemd/system/vaultwarden.service` | listens on `127.0.0.1:8000` by default |

Put a reverse proxy (nginx/Caddy) with TLS in front, set `DOMAIN` in the env file, then `systemctl restart vaultwarden`.

## Manual run

Actions → Release → Run workflow. Optionally set a version, and `force` to repackage an existing release.
