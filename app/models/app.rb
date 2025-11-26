class App < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :repository, presence: true, format: { with: /\A(https?:\/\/)?(www\.)?(github\.com|gitlab\.com|bitbucket\.org)\/[\w\-]+\/[\w\-]+/i, message: "must be a valid GitHub, GitLab, or Bitbucket repository URL" }

  # Extract repository name from URL
  def repository_name
    return nil unless repository.present?

    # Extract from various formats:
    # https://github.com/owner/repo
    # git@github.com:owner/repo.git
    # github.com/owner/repo
    match = repository.match(%r{(?:github\.com|gitlab\.com|bitbucket\.org)[:/]([\w\-]+)/([\w\-]+?)(?:\.git)?$}i)
    match ? "#{match[1]}/#{match[2]}" : repository
  end

  # Extract owner from repository
  def repository_owner
    return nil unless repository.present?

    match = repository.match(%r{(?:github\.com|gitlab\.com|bitbucket\.org)[:/]([\w\-]+)/}i)
    match ? match[1] : nil
  end

  # Get clean repository name without owner
  def repository_short_name
    return nil unless repository.present?

    match = repository.match(%r{/([\w\-]+?)(?:\.git)?$})
    match ? match[1] : repository
  end

  # Determine repository platform
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
      "Unknown"
    end
  end

  # Get clean URL for display
  def repository_url
    return nil unless repository.present?

    # If it already has http/https, return it
    return repository if repository.match?(/^https?:\/\//)

    # If it's git@ format, convert to https
    if repository.match?(/^git@/)
      repository.gsub(/^git@([^:]+):/, 'https://\1/')
    else
      # Assume it's just the domain/path
      "https://#{repository}"
    end
  end
end
