#!/bin/bash

name="vault"

latest_version() {
  remote_versions | head -n 1
}

remote_versions() {
  curl -Ls "https://releases.hashicorp.com/${name}/" | grep "href=\"/${name}" | sed "s/^.*>${name}_\([0-9]*\.[0-9]*\.[0-9*]\).*$/\1/" | sort -Vru
}

_url() {
  #[ "${version:0:1}" == "v" ] || version="v${version}"

  echo "https://releases.hashicorp.com/${name}/${version}/${name}_${version}_${os_type}_${os_arch}.zip"
}

install() {
  version=$1
  os_type=$2
  os_arch=$3
  install_path=$4

  tmpdir="$(mktemp -d)"
  if (cd "$tmpdir" && curl -Lsfo "${name}.zip" "$(_url)" && unzip "${name}.zip" && mv "$name" "$install_path"); then
    rm -rf "$tmpdir"
    chmod +x "$install_path"
  else
    rm -rf "$tmpdir"
    cat <<EOT
Unable to download
URL: $(_url)
path: $install_path
EOT
    exit 1
  fi
}

#_belt_completion_kubectl() {
#  case "$1" in
#    bash)
#      #source <(kubectl completion bash)
#      ;;
#    zsh)
#      _kubectl_lazy_completion() {
#      #  source <(kubectl completion zsh)
#        unset -f _kubectl_lazy_completion
#      }
#      compdef _kubectl_lazy_completion kubectl
#      ;;
#    *)
#      echo "shell not supported"
#      exit 5
#  esac
#}

# TODO: Fix completion, I believe this is the closest
#if [ -n "$ZSH_VERSION" ]; then
#  _kubectl_lazy_completion() {
#    source <(kubectl completion zsh)
#    unset -f _kubectl_lazy_completion
#  }
#  compdef _kubectl_lazy_completion kubectl
#elif [ -n "$BASH_VERSION" ]; then
#  source <(kubectl completion bash)
#fi

action=$1; shift
"${action}" "$@"
