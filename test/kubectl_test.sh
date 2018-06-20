. ./test/helper.sh

function kubectl_version_parse()
{
  key=$1
  awk -F"[,:]" '{for(i=1;i<=NF;i++){if($i~/'$key'/){print $(i+1)}}}' | tr -d '"'
}


function test_kubectl_function()
{
  echo $(command -v kubectl) | grep '^/' > /dev/null

  assertNotEquals "kubectl command starts with /" 1 $?
}

function test_kubectl_environment_version()
{
  local TK_KUBECTL_VERSION="v1.10.3"
  local client_version=$(kubectl version | kubectl_version_parse 'GitVersion' )

  assertEquals "version doesn't match ENV" $TK_KUBECTL_VERSION $client_version
}

SHUNIT_PARENT=$0 . $SHUNIT2
