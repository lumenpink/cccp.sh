# Set the shell options for testing
set -e

cd "$SHELLSPEC_PROJECT_ROOT"

# Determine which version to test based on environment variable
if [ "${TEST_VERSION:-destructured}" = "combined" ]; then
  # Generate the combined version if it doesn't exist or is older than source files
  if [ ! -f "cccp.sh" ] || [ "cccp.sh" -ot "cccp-base.sh" ]; then
    ./combine.sh
  fi
  export GIT_HOOK_FILE="cccp.sh"
  # For combined version, we don't need to include individual files
  # as they're all included in cccp.sh
else
  export GIT_HOOK_FILE="cccp-base.sh"
  # For destructured version, we need to include config and other dependencies
  . "$SHELLSPEC_PROJECT_ROOT/src/config/config.sh"
fi

# Helper function to include test dependencies
include_test_dependencies() {
  if [ "${TEST_VERSION:-destructured}" != "combined" ]; then
    # Only include the specified file for destructured version
    . "$1"
  fi
}

# Helper function to create a test git repository
setup_test_repository() {
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
  
  # Copy the src directory to the test directory
  if [ "${TEST_VERSION:-destructured}" != "combined" ]; then
    cp -a "$SHELLSPEC_PROJECT_ROOT/src" "$TEST_DIR"
  fi

  # Initialize git repository
  git init
  git config user.email "test@example.com"
  git config user.name "Test User"
    
  # Create initial commit
  touch README.md
  git add README.md
  git commit --no-verify -m "initial commit" 
  git tag -a "v1.0.0" -m "Version 1.0.0"

  echo "$TEST_DIR"
}

# Helper function to clean up test repository
cleanup_test_repository() {
  rm -rf "$1"
}

# Helper function to create a test commit
create_test_commit() {
  echo "test" >> test.txt
  git add test.txt
  git commit -m "$1"
}

# Export variables instead of functions
export TEST_DIR
export SHELLSPEC_PROJECT_ROOT
export TEST_VERSION 