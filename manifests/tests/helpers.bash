setup() {
  cd "$BATS_TEST_DIRNAME/.."
  RENDERED="$(helm template . )"
  export RENDERED
}
