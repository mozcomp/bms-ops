class App < ApplicationRecord
  has_many :instances, dependent: :destroy

  # Comprehensive regex for repository URL validation
  # Supports:
  # - HTTPS: https://github.com/owner/repo or https://github.com/owner/repo.git
  # - SSH: git@github.com:owner/repo or git@github.com:owner/repo.git
  # - Short: github.com/owner/repo
  REPO_REGEX = %r{
    \A
    (?:
      (?:https?://)?(?:www\.)?(?:github\.com|gitlab\.com|bitbucket\.org)/[\w\-\.]+/[\w\-\.]+(?:\.git)?
      |
      git@(?:github\.com|gitlab\.com|bitbucket\.org):[\w\-\.]+/[\w\-\.]+(?:\.git)?
    )
    \z
  }ix

  validates :name, presence: true, uniqueness: true
  validates :repository, presence: true, format: { 
    with: REPO_REGEX, 
    message: "must be a valid GitHub, GitLab, or Bitbucket repository URL in HTTPS, SSH, or short format" 
  }

  # Extract repository name from URL (returns "owner/repo" format)
  def repository_name
    return nil unless repository.present?

    # Extract from various formats:
    # https://github.com/owner/repo
    # git@github.com:owner/repo.git
    # github.com/owner/repo
    match = repository.match(%r{(?:github\.com|gitlab\.com|bitbucket\.org)[:/]([\w\-\.]+)/([\w\-\.]+?)(?:\.git)?$}i)
    match ? "#{match[1]}/#{match[2]}" : nil
  end

  # Extract owner from repository URL
  def repository_owner
    return nil unless repository.present?

    match = repository.match(%r{(?:github\.com|gitlab\.com|bitbucket\.org)[:/]([\w\-\.]+)/}i)
    match ? match[1] : nil
  end

  # Get clean repository name without owner (just the repo name)
  def repository_short_name
    return nil unless repository.present?

    match = repository.match(%r{/([\w\-\.]+?)(?:\.git)?$})
    match ? match[1] : nil
  end

  # Determine repository platform (GitHub, GitLab, or Bitbucket)
  def repository_platform
    return nil unless repository.present?

    case repository.downcase
    when /github\.com/
      "GitHub"
    when /gitlab\.com/
      "GitLab"
    when /bitbucket\.org/
      "Bitbucket"
    else
      nil
    end
  end

  # Get clean HTTPS URL for display (converts SSH to HTTPS, removes .git suffix)
  def repository_url
    return nil unless repository.present?

    # If it's git@ format (SSH), convert to https
    if repository.match?(/^git@/)
      url = repository.gsub(/^git@([^:]+):/, 'https://\1/')
      # Remove .git suffix if present
      url = url.gsub(/\.git$/, '')
      return url
    end

    # If it already has http/https, clean it up
    if repository.match?(/^https?:\/\//)
      # Remove .git suffix if present
      return repository.gsub(/\.git$/, '')
    end

    # Assume it's just the domain/path (short format)
    url = "https://#{repository}"
    # Remove .git suffix if present
    url.gsub(/\.git$/, '')
  end
end
