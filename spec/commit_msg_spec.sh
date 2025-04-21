# Include the test helper
. "$SHELLSPEC_PROJECT_ROOT/spec/spec_helper.sh"

Describe 'commit_msg'
  include_test_dependencies "$SHELLSPEC_PROJECT_ROOT/src/utils/validation.sh"
  include_test_dependencies "$SHELLSPEC_PROJECT_ROOT/src/hooks/commit_msg.sh"
  

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

  Describe 'commit_msg'
    It 'accepts valid commit message'
      When call commit_msg "feat: add new feature"
      The status should be success
    End

    It 'rejects invalid commit message'
      When call commit_msg "invalid: some message"
      The status should be failure
      The output should include "Error: Invalid type 'invalid'"
    End

    It 'handles empty commit message'
      When call commit_msg ""
      The status should be failure
      The output should include "Error: Commit message cannot be empty"
    End

    It 'handles commit message with only whitespace'
      When call commit_msg "   "
      The status should be failure
      The output should include "Error: Commit message cannot be empty"
    End

    It 'handles commit message with newlines'
      When call commit_msg "feat: add new feature\n\nSome description"
      The status should be success
    End
  End
End 