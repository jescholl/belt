_belt_module_kubectl_latest() {
  curl -Ls https://storage.googleapis.com/kubernetes-release/release/stable.txt
}


_belt_module_kubectl_url() {
  local os_type=${1}
  local os_arch=${2/i386/386}
  local version=${4:-$(_belt_module_kubectl_latest)}

  echo https://storage.googleapis.com/kubernetes-release/release/${version}/bin/${os_type}/${os_arch}/kubectl
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
_belt_module_kubectl_${action} $@
