require "test_helper"

class AppPropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 6: App creation and persistence
  # Validates: Requirements 2.1
  test "app creation with valid name and repository persists to database" do
    100.times do
      # Generate random valid app data
      name = generate_app_name
      repository = generate_repository_url
      
      # Create app
      app = App.create!(
        name: name,
        repository: repository
      )
      
      # Verify app was persisted
      assert app.persisted?, "App should be persisted to database"
      assert_not_nil app.id, "App should have an ID"
      assert_equal name, app.name, "App name should match"
      assert_equal repository, app.repository, "App repository should match"
      
      # Clean up
      app.destroy!
    end
  end

  # Feature: infrastructure-management, Property 7: Repository URL format acceptance
  # Validates: Requirements 2.2
  test "repository URL accepts GitHub, GitLab, and Bitbucket URLs in HTTPS, SSH, and short formats" do
    platforms = ["github.com", "gitlab.com", "bitbucket.org"]
    formats = [:https, :ssh, :https_with_git, :ssh_with_git]
    
    # Test each platform with each format
    platforms.each do |platform|
      formats.each do |format|
        25.times do
          owner = generate_repo_owner
          repo = generate_repo_name
          
          # Generate URL in specific format
          url = case format
          when :https
            "https://#{platform}/#{owner}/#{repo}"
          when :ssh
            "git@#{platform}:#{owner}/#{repo}"
          when :https_with_git
            "https://#{platform}/#{owner}/#{repo}.git"
          when :ssh_with_git
            "git@#{platform}:#{owner}/#{repo}.git"
          end
          
          # Create app with this URL
          app = App.create!(
            name: "#{generate_app_name}-#{SecureRandom.hex(4)}",
            repository: url
          )
          
          # Verify app was created successfully
          assert app.persisted?, "App should accept #{format} format for #{platform}"
          assert_equal url, app.repository, "Repository URL should be stored as-is"
          
          # Clean up
          app.destroy!
        end
      end
    end
  end

  # Feature: infrastructure-management, Property 8: App computed fields correctness
  # Validates: Requirements 2.3
  test "app computed fields correctly extract repository information" do
    100.times do
      # Generate random repository data
      platform = generate_repo_platform
      owner = generate_repo_owner
      repo = generate_repo_name
      format = Rantly { choose(:https, :ssh, :https_with_git, :ssh_with_git) }
      
      # Generate URL in specific format
      url = case format
      when :https
        "https://#{platform}/#{owner}/#{repo}"
      when :ssh
        "git@#{platform}:#{owner}/#{repo}"
      when :https_with_git
        "https://#{platform}/#{owner}/#{repo}.git"
      when :ssh_with_git
        "git@#{platform}:#{owner}/#{repo}.git"
      end
      
      # Create app
      app = App.create!(
        name: "#{generate_app_name}-#{SecureRandom.hex(4)}",
        repository: url
      )
      
      # Verify repository_owner is correct
      assert_equal owner, app.repository_owner, "Repository owner should be extracted correctly"
      
      # Verify repository_short_name is correct (without .git)
      assert_equal repo, app.repository_short_name, "Repository short name should be extracted correctly"
      
      # Verify repository_name is correct (owner/repo format)
      assert_equal "#{owner}/#{repo}", app.repository_name, "Repository name should be in owner/repo format"
      
      # Verify platform detection
      expected_platform = case platform
      when "github.com"
        "GitHub"
      when "gitlab.com"
        "GitLab"
      when "bitbucket.org"
        "Bitbucket"
      end
      assert_equal expected_platform, app.repository_platform, "Platform should be detected correctly"
      
      # Verify clean HTTPS URL (no .git suffix)
      clean_url = app.repository_url
      assert clean_url.start_with?("https://"), "Clean URL should start with https://"
      assert_not clean_url.end_with?(".git"), "Clean URL should not end with .git"
      assert clean_url.include?("#{owner}/#{repo}"), "Clean URL should contain owner/repo"
      
      # Clean up
      app.destroy!
    end
  end

  # Feature: infrastructure-management, Property 9: Invalid repository rejection
  # Validates: Requirements 2.5, 6.4
  test "invalid repository URLs are rejected with validation error" do
    100.times do
      # Generate invalid repository URL
      invalid_url = generate_invalid_repository_url
      name = "#{generate_app_name}-#{SecureRandom.hex(4)}"
      
      # Attempt to create app with invalid URL
      app = App.new(
        name: name,
        repository: invalid_url
      )
      
      # Verify validation fails
      assert_not app.valid?, "App with invalid repository should not be valid"
      assert app.errors[:repository].any?, "Repository field should have validation errors"
      
      # Verify app is not persisted
      assert_not app.persisted?, "Invalid app should not be persisted"
    end
  end

  # Feature: infrastructure-management, Property 18: Repository URL parsing completeness
  # Validates: Requirements 8.1, 8.2, 8.3
  test "repository URL parsing extracts owner and repo from all formats and removes .git suffix" do
    100.times do
      # Generate random repository data
      platform = generate_repo_platform
      owner = generate_repo_owner
      repo = generate_repo_name
      
      # Test with and without .git suffix
      has_git_suffix = Rantly { choose(true, false) }
      format = Rantly { choose(:https, :ssh) }
      
      # Generate URL
      url = case format
      when :https
        base = "https://#{platform}/#{owner}/#{repo}"
        has_git_suffix ? "#{base}.git" : base
      when :ssh
        base = "git@#{platform}:#{owner}/#{repo}"
        has_git_suffix ? "#{base}.git" : base
      end
      
      # Create app
      app = App.create!(
        name: "#{generate_app_name}-#{SecureRandom.hex(4)}",
        repository: url
      )
      
      # Verify owner extraction (should work regardless of .git suffix)
      assert_equal owner, app.repository_owner, "Owner should be extracted correctly"
      
      # Verify repo extraction (should remove .git suffix)
      assert_equal repo, app.repository_short_name, "Repo name should be extracted without .git suffix"
      
      # Verify full name extraction
      assert_equal "#{owner}/#{repo}", app.repository_name, "Full name should be owner/repo without .git"
      
      # Clean up
      app.destroy!
    end
  end

  # Feature: infrastructure-management, Property 19: Repository platform detection
  # Validates: Requirements 8.4
  test "repository platform is correctly identified for GitHub, GitLab, and Bitbucket" do
    platforms = {
      "github.com" => "GitHub",
      "gitlab.com" => "GitLab",
      "bitbucket.org" => "Bitbucket"
    }
    
    platforms.each do |domain, expected_platform|
      25.times do
        owner = generate_repo_owner
        repo = generate_repo_name
        format = Rantly { choose(:https, :ssh) }
        
        # Generate URL
        url = case format
        when :https
          "https://#{domain}/#{owner}/#{repo}"
        when :ssh
          "git@#{domain}:#{owner}/#{repo}"
        end
        
        # Create app
        app = App.create!(
          name: "#{generate_app_name}-#{SecureRandom.hex(4)}",
          repository: url
        )
        
        # Verify platform detection
        assert_equal expected_platform, app.repository_platform, 
          "Platform should be detected as #{expected_platform} for #{domain}"
        
        # Clean up
        app.destroy!
      end
    end
  end

  # Feature: infrastructure-management, Property 20: SSH to HTTPS URL conversion
  # Validates: Requirements 8.5
  test "SSH repository URLs are converted to clean HTTPS format" do
    100.times do
      # Generate SSH format URL
      platform = generate_repo_platform
      owner = generate_repo_owner
      repo = generate_repo_name
      has_git_suffix = Rantly { choose(true, false) }
      
      ssh_url = "git@#{platform}:#{owner}/#{repo}"
      ssh_url += ".git" if has_git_suffix
      
      # Create app with SSH URL
      app = App.create!(
        name: "#{generate_app_name}-#{SecureRandom.hex(4)}",
        repository: ssh_url
      )
      
      # Get clean URL
      clean_url = app.repository_url
      
      # Verify conversion to HTTPS
      assert clean_url.start_with?("https://"), "SSH URL should be converted to HTTPS"
      assert_equal "https://#{platform}/#{owner}/#{repo}", clean_url, 
        "SSH URL should be converted to clean HTTPS format without .git"
      
      # Verify no git@ prefix remains
      assert_not clean_url.include?("git@"), "Converted URL should not contain git@"
      
      # Verify no colon separator remains (SSH uses :, HTTPS uses /)
      # After the protocol, there should be no colons
      url_without_protocol = clean_url.sub("https://", "")
      assert_not url_without_protocol.include?(":"), "Converted URL should not contain : separator"
      
      # Clean up
      app.destroy!
    end
  end
end
