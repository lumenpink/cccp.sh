# Include the test helper
. "$SHELLSPEC_PROJECT_ROOT/spec/spec_helper.sh"

Describe 'hooks'
  include_test_dependencies "$SHELLSPEC_PROJECT_ROOT/src/hooks/hooks.sh"

  setup() {
    # Create a temporary directory for the test repository
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
    
    # Initialize git repository
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    touch README.md
    git add README.md
    git commit -m "initial commit"
  }

  cleanup() {
    # Clean up the temporary directory
    rm -rf "$TEST_DIR"
  }

  BeforeAll 'setup'
  AfterAll 'cleanup'

  Describe 'install_git_hooks'
    It 'creates hook files'
      When call install_git_hooks
      The file ".git/hooks/commit-msg" should be exist
      The file ".git/hooks/post-commit" should be exist
    End

    It 'makes hook files executable'
      When call install_git_hooks
      The file ".git/hooks/commit-msg" should be executable
      The file ".git/hooks/post-commit" should be executable
    End

    It 'preserves existing hooks'
      # Create a pre-existing hook
      mkdir -p .git/hooks
      echo "#!/bin/sh" > .git/hooks/commit-msg
      echo "echo 'pre-existing hook'" >> .git/hooks/commit-msg
      chmod +x .git/hooks/commit-msg

      When call install_git_hooks
      The file ".git/hooks/commit-msg" should be exist
      The contents of file ".git/hooks/commit-msg" should include "pre-existing hook"
    End
  End
End 