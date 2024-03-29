#!/usr/bin/env bash

CI="${CI:-false}"
TMPDIR=${TMPDIR:-/tmp}
MAC_OS_SWITCH_TO_UNIVERSAL='1.11.1'
(which unzip >/dev/null) || (echo >&2 'unzip is needed to install 1password' && exit 1)

TOOL_NAME='1password-cli'

successfully() {
  if ! "$@"; then
    exit 1
  fi
}

darwin_install() {
  local bin_install_path="${1}"
  local download_url="${2}"
  local bin_path="${bin_install_path}/op"
  echo "Downloading op from ${download_url}"

  local tmp_dir="$(mktemp -d)"
  local pkg_path="${tmp_dir}/op.pkg"
  successfully curl --fail-with-body -s "$download_url" -o "${pkg_path}"

  sudo installer -pkg "${pkg_path}" -target /
  # lame
  sudo mv "$(which op)" "${bin_path}"
}

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

all_else_install() {
  local bin_install_path="${1}"
  local download_url="${2}"
  local bin_path="${bin_install_path}/op"
  local zip_path="${bin_install_path}/op.zip"
  local sig_path="${bin_install_path}/op.sig"
  echo "Downloading op from ${download_url}"

  successfully curl --fail-with-body -s "$download_url" -o "$zip_path"
  successfully unzip "${zip_path}" -d "${bin_install_path}"
  rm "${zip_path}" "${sig_path}"
  local -r group_name="onepassword-cli"
  # https://1password.community/discussion/comment/657013/#Comment_657013
  if ! grep -q -E "^${group_name}:" /etc/group; then
    if [ "${CI}" = "true" ]; then
      sudo groupadd "${group_name}"
      sudo usermod -a -G "${group_name}" "$(whoami)"
    else
      read -rp "'${group_name}' group needs created to run this program, continue? (y/n): " yn
      if [ "${yn}" = "y" ]; then
        sudo groupadd "${group_name}"
      else
        fail "cannot create '${group_name}' group install cannot continue"
      fi
    fi
  fi
  sudo chgrp "${group_name}" "${bin_path}"
  chmod g+s "${bin_path}"
  chmod +x "${bin_path}"
}

get_arch() {
  uname | tr '[:upper:]' '[:lower:]'
}

semver_compare() {
  local -r a="${1}"
  local -r b="${2}"

  if [[ "${a}" = "${b}" ]]; then
    printf 0
  else
    local -r largest_version="$(printf "%s\n%s" "${a}" "${b}" | sort -V | tail -n 1)"

    if [[ "${a}" = "${largest_version}" ]]; then
      printf 1
    else
      printf -1
    fi
  fi
}

list_all_versions() {
  curl -s https://app-updates.agilebits.com/product_history/CLI | sed -n '/<h3/{n;p;}' | sed 's/^[ \t]*//' &&
    curl -s https://app-updates.agilebits.com/product_history/CLI2 | sed -n '/<h3/{n;p;}' | sed 's/^[ \t]*//'
}

sort_versions() {
  sort -V
}

get_download_url() {
  local version="$1"
  local platform="$2"
  local -r major="$(cut -d'.' -f1 <<<"${version}")"
  local major_string="2"
  if [ "${major}" = "1" ]; then
    major_string=""
  fi
  if [ "${platform}" = "darwin" ]; then
    local -r comparison="$(semver_compare "${version}" "${MAC_OS_SWITCH_TO_UNIVERSAL}")"
    if [ "${comparison}" = "0" ] || [ "${comparison}" = "-1" ]; then
      echo "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_${platform}_amd64_v${version}.pkg"
    else
      echo "https://cache.agilebits.com/dist/1P/op${major_string}/pkg/v${version}/op_apple_universal_v${version}.pkg"
    fi
  else
    echo "https://cache.agilebits.com/dist/1P/op${major_string}/pkg/v${version}/op_${platform}_amd64_v${version}.zip"
  fi
}

install_version() {
  local install_type="${1}"
  local -r version="${2}"
  local install_path="${3}"
  local bin_install_path="$install_path/bin"
  local -r platform="$(get_arch)"
  local -r download_url="$(get_download_url "${version}" "${platform}")"

  mkdir -p "${bin_install_path}"

  if [ "${platform}" = 'darwin' ]; then
    darwin_install "${bin_install_path}" "${download_url}"
  else
    all_else_install "${bin_install_path}" "${download_url}"
  fi
}
