. ./test/helper.sh


function test_environment_pollution()
{
  assertNull "belt is polluting the environment" "$SOURCE"
}
function test_belt_module()
{
  assertTrue "BELT_MODULE_DIR does not exist" "[ -d $BELT_MODULE_DIR ]"

}

# FIXME: I need to test (somewhere, not necessarily here) that it works from other directories
# or that the path is fully qualified and exists

SHUNIT_PARENT=$0 . $SHUNIT2
