require "test_helper"

class AppTest < ActiveSupport::TestCase
  # Validation tests
  test "should require name" do
    app = App.new(repository: "https://github.com/owner/repo")
    assert_not app.valid?
    assert_includes app.errors[:name], "can't be blank"
  end

  test "should require repository" do
    app = App.new(name: "Test App")
    assert_not app.valid?
    assert_includes app.errors[:repository], "can't be blank"
  end

  test "should require unique name" do
    App.create!(name: "Unique App", repository: "https://github.com/owner/repo1")
    app = App.new(name: "Unique App", repository: "https://github.com/owner/repo2")
    assert_not app.valid?
    assert_includes app.errors[:name], "has already been taken. Each app must have a unique name."
  end

  # Repository URL format validation tests
  test "should accept GitHub HTTPS URL" do
    app = App.new(name: "Test App", repository: "https://github.com/owner/repo")
    assert app.valid?
  end

  test "should accept GitHub SSH URL" do
    app = App.new(name: "Test App", repository: "git@github.com:owner/repo")
    assert app.valid?
  end

  test "should accept GitHub URL with .git suffix" do
    app = App.new(name: "Test App", repository: "https://github.com/owner/repo.git")
    assert app.valid?
  end

  test "should accept GitLab HTTPS URL" do
    app = App.new(name: "Test App", repository: "https://gitlab.com/owner/repo")
    assert app.valid?
  end

  test "should accept GitLab SSH URL" do
    app = App.new(name: "Test App", repository: "git@gitlab.com:owner/repo")
    assert app.valid?
  end

  test "should accept Bitbucket HTTPS URL" do
    app = App.new(name: "Test App", repository: "https://bitbucket.org/owner/repo")
    assert app.valid?
  end

  test "should accept Bitbucket SSH URL" do
    app = App.new(name: "Test App", repository: "git@bitbucket.org:owner/repo")
    assert app.valid?
  end

  test "should reject invalid repository URL" do
    app = App.new(name: "Test App", repository: "not a valid url")
    assert_not app.valid?
    assert_includes app.errors[:repository], "must be a valid GitHub, GitLab, or Bitbucket repository URL in HTTPS, SSH, or short format"
  end

  test "should reject FTP URL" do
    app = App.new(name: "Test App", repository: "ftp://github.com/owner/repo")
    assert_not app.valid?
  end

  test "should reject URL without owner/repo" do
    app = App.new(name: "Test App", repository: "https://github.com/")
    assert_not app.valid?
  end

  # Repository parsing tests
  test "repository_name extracts owner/repo from HTTPS URL" do
    app = App.create!(name: "Test App", repository: "https://github.com/myowner/myrepo")
    assert_equal "myowner/myrepo", app.repository_name
  end

  test "repository_name extracts owner/repo from SSH URL" do
    app = App.create!(name: "Test App", repository: "git@github.com:myowner/myrepo")
    assert_equal "myowner/myrepo", app.repository_name
  end

  test "repository_name removes .git suffix" do
    app = App.create!(name: "Test App", repository: "https://github.com/myowner/myrepo.git")
    assert_equal "myowner/myrepo", app.repository_name
  end

  test "repository_owner extracts owner from HTTPS URL" do
    app = App.create!(name: "Test App", repository: "https://github.com/myowner/myrepo")
    assert_equal "myowner", app.repository_owner
  end

  test "repository_owner extracts owner from SSH URL" do
    app = App.create!(name: "Test App", repository: "git@github.com:myowner/myrepo")
    assert_equal "myowner", app.repository_owner
  end

  test "repository_short_name extracts repo name without owner" do
    app = App.create!(name: "Test App", repository: "https://github.com/myowner/myrepo")
    assert_equal "myrepo", app.repository_short_name
  end

  test "repository_short_name removes .git suffix" do
    app = App.create!(name: "Test App", repository: "https://github.com/myowner/myrepo.git")
    assert_equal "myrepo", app.repository_short_name
  end

  # Platform detection tests
  test "repository_platform detects GitHub" do
    app = App.create!(name: "Test App", repository: "https://github.com/owner/repo")
    assert_equal "GitHub", app.repository_platform
  end

  test "repository_platform detects GitLab" do
    app = App.create!(name: "Test App", repository: "https://gitlab.com/owner/repo")
    assert_equal "GitLab", app.repository_platform
  end

  test "repository_platform detects Bitbucket" do
    app = App.create!(name: "Test App", repository: "https://bitbucket.org/owner/repo")
    assert_equal "Bitbucket", app.repository_platform
  end

  test "repository_platform is case insensitive" do
    app = App.create!(name: "Test App", repository: "https://GitHub.com/owner/repo")
    assert_equal "GitHub", app.repository_platform
  end

  # URL conversion tests
  test "repository_url returns HTTPS URL as-is without .git" do
    app = App.create!(name: "Test App", repository: "https://github.com/owner/repo.git")
    assert_equal "https://github.com/owner/repo", app.repository_url
  end

  test "repository_url converts SSH to HTTPS" do
    app = App.create!(name: "Test App", repository: "git@github.com:owner/repo")
    assert_equal "https://github.com/owner/repo", app.repository_url
  end

  test "repository_url converts SSH with .git to HTTPS without .git" do
    app = App.create!(name: "Test App", repository: "git@github.com:owner/repo.git")
    assert_equal "https://github.com/owner/repo", app.repository_url
  end

  test "repository_url handles short format" do
    app = App.create!(name: "Test App", repository: "github.com/owner/repo")
    assert_equal "https://github.com/owner/repo", app.repository_url
  end

  # Edge cases
  test "handles repository names with hyphens" do
    app = App.create!(name: "Test App", repository: "https://github.com/my-owner/my-repo")
    assert_equal "my-owner", app.repository_owner
    assert_equal "my-repo", app.repository_short_name
    assert_equal "my-owner/my-repo", app.repository_name
  end

  test "handles repository names with dots" do
    app = App.create!(name: "Test App", repository: "https://github.com/my.owner/my.repo")
    assert_equal "my.owner", app.repository_owner
    assert_equal "my.repo", app.repository_short_name
    assert_equal "my.owner/my.repo", app.repository_name
  end

  test "handles repository names with underscores" do
    app = App.create!(name: "Test App", repository: "https://github.com/my_owner/my_repo")
    assert_equal "my_owner", app.repository_owner
    assert_equal "my_repo", app.repository_short_name
    assert_equal "my_owner/my_repo", app.repository_name
  end

  test "returns nil for computed fields when repository is nil" do
    app = App.new(name: "Test App")
    assert_nil app.repository_name
    assert_nil app.repository_owner
    assert_nil app.repository_short_name
    assert_nil app.repository_platform
    assert_nil app.repository_url
  end
end
