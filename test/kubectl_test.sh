. ./test/helper.sh

function _kubectl_version_parse()
{
  key=$1
  awk -F"[,:]" "{for(i=1;i<=NF;i++){if(\$i~/$key/){print \$(i+1)}}}" | tr -d '"'
}


function test_kubectl_is_a_function()
{
  local kubectl_path="$(command -v kubectl)"

  assertEquals "kubectl is not a function" "kubectl" "$kubectl_path"
}

function test_kubectl_environment()
{
  local BELT_KUBECTL_VERSION="v1.10.3"
  local client_version=$(kubectl version 2> /dev/null | _kubectl_version_parse 'GitVersion' )
  assertEquals "version doesn't match ENV" "v1.10.3" "$client_version"

  local BELT_KUBECTL_VERSION="v1.10.5"
  local client_version=$(kubectl version 2> /dev/null | _kubectl_version_parse 'GitVersion' )
  assertEquals "version doesn't match ENV" "v1.10.5" "$client_version"
}

function test_latest()
{
  local latest_version=$(belt latest kubectl)
  assertNotEquals "'latest' is empty" "$latest_version" ""
}

function test_url()
{
  local url
  url=$(belt module kubectl url darwin amd64 "v1.10.5")
  assertTrue "Unable to download: $url" "curl -Ifs $url"

  url=$(belt module kubectl url darwin i386)
  assertTrue "Unable to download: $url" "curl -Ifs $url"

  url=$(belt module kubectl url linux amd64)
  assertTrue "Unable to download: $url" "curl -Ifs $url"

  url=$(belt module kubectl url linux i386)
  assertTrue "Unable to download: $url" "curl -Ifs $url"
}

SHUNIT_PARENT=$0 . $SHUNIT2
