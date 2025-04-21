# Include the test helper
. "$SHELLSPEC_PROJECT_ROOT/spec/spec_helper.sh"

Describe 'commit'
  include_test_dependencies "$SHELLSPEC_PROJECT_ROOT/src/utils/commit.sh"

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

  Describe 'commit'
    It 'creates a valid commit'
      echo "test" >> test.txt
      git add test.txt
      When call commit "feat: add test file"
      The status should be success
      The output should include "Commit created successfully"
    End

    It 'rejects invalid commit message'
      echo "test" >> test.txt
      git add test.txt
      When call commit "invalid: some message"
      The status should be failure
      The output should include "Error: Invalid type 'invalid'"
    End

    It 'handles empty commit message'
      echo "test" >> test.txt
      git add test.txt
      When call commit ""
      The status should be failure
      The output should include "Error: Commit message cannot be empty"
    End

    It 'handles no staged changes'
      When call commit "feat: no changes"
      The status should be failure
      The output should include "Error: No changes staged for commit"
    End
  End
End