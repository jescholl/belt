#!/bin/bash

latest_version() {
  curl -Ls https://storage.googleapis.com/kubernetes-release/release/stable.txt | sed 's/v\(.*\)/\1/'
}

remote_versions() {
  echo "Not supported" >&2
}


_url() {
  [ "${version:0:1}" == "v" ] || version="v${version}"

  echo "https://storage.googleapis.com/kubernetes-release/release/${version}/bin/${os_type}/${os_arch}/kubectl"
}

install() {
  version=$1
  os_type=$2
  os_arch=$3
  install_path=$4

  echo curl -Lsfo "$install_path" "$(_url)"
  if curl -Lsfo "$install_path" "$(_url)"; then
    chmod +x "$install_path"
  else
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
