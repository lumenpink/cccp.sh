# Include the test helper
. "$SHELLSPEC_PROJECT_ROOT/spec/spec_helper.sh"

Describe 'version'
  include_test_dependencies "$SHELLSPEC_PROJECT_ROOT/src/utils/version.sh"

  BeforeAll 'setup_test_repository'
  AfterAll 'cleanup_test_repository'

  Describe 'generate_version_info'
    BeforeEach 'rm -f VERSION'

    It 'creates VERSION file'
      When call generate_version_info
      The output should eq "Version information written to VERSION file"
      The file VERSION should be exist
      cat VERSION
    End

    It 'includes version tag'
      When call generate_version_info
      The output should be present
      The contents of file VERSION should include "v1.0.0"
    End

    It 'includes commit count'
      # Add a new commit
      echo "test" >> test.txt
      git add test.txt
      git commit -m "test commit"
      
      When call generate_version_info
      The output should be present
      The contents of file VERSION should match pattern "v1.0.0+1.*"
    End

    It 'includes date'
      current_date="$(date +%Y%m%d)"
      When call generate_version_info
      The output should be present
      The contents of file VERSION should include "$current_date"
    End

    It 'includes commit hash'
      commit_hash="$(git log -n 2 --format=%h | tail -n 1)"
      When call generate_version_info
      The output should be present
      The contents of file VERSION should include "$commit_hash"
    End

    It 'generates version info for untagged commit'
      When call generate_version_info
      The output should include "Version: 0.0.0"
      The output should include "Commit:"
    End

    It 'generates version info for tagged commit'
      git tag -a "v1.0.0" -m "Version 1.0.0"
      When call generate_version_info
      The output should include "Version: 1.0.0"
      The output should include "Commit:"
    End

    It 'handles multiple tags'
      git tag -a "v1.0.0" -m "Version 1.0.0"
      git tag -a "v1.1.0" -m "Version 1.1.0"
      When call generate_version_info
      The output should include "Version: 1.1.0"
    End

    It 'handles pre-release tags'
      git tag -a "v1.0.0-alpha" -m "Version 1.0.0-alpha"
      When call generate_version_info
      The output should include "Version: 1.0.0-alpha"
    End
  End
End 