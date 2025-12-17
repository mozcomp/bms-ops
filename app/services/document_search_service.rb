class DocumentSearchService
  attr_reader :query, :user, :results, :filters, :sort_by

  def initialize(query, user = nil, options = {})
    @query = query.to_s.strip
    @user = user
    @results = []
    @filters = options[:filters] || {}
    @sort_by = options[:sort_by] || 'relevance'
  end

  def search
    return Document.none if @query.blank?

    begin
      # Start with published documents
      documents = Document.published.includes(:folder, :created_by, :updated_by)
      
      # Apply permission filtering
      documents = apply_permission_filter(documents)
      
      # Apply search filtering
      documents = apply_search_filter(documents)
      
      # Apply additional filters
      documents = apply_filters(documents)
      
      # Apply sorting and ranking
      @results = apply_sorting_and_limit(documents)
      
      @results
    rescue StandardError => e
      Rails.logger.error "DocumentSearchService error: #{e.message}"
      Document.none
    end
  end

  def search_suggestions(limit = 5)
    return [] if @query.blank? || @query.length < 2

    # Get suggestions from document titles and folder names
    title_suggestions = Document.published.visible_to(@user)
                               .where("title LIKE ?", "#{@query}%")
                               .limit(limit)
                               .pluck(:title)
                               .map { |title| { type: 'document', text: title } }

    folder_suggestions = Folder.where("name LIKE ?", "#{@query}%")
                              .limit(limit)
                              .pluck(:name)
                              .map { |name| { type: 'folder', text: name } }

    (title_suggestions + folder_suggestions).first(limit)
  end

  def recent_searches(limit = 10)
    # This would typically be stored in user preferences or session
    # For now, return empty array - can be enhanced later
    []
  end

  def search_with_excerpts
    search_results = search
    
    search_results.map do |document|
      {
        document: document,
        excerpt: generate_excerpt(document),
        relevance_score: calculate_relevance_score(document),
        hierarchy_path: generate_hierarchy_path(document)
      }
    end
  end

  def highlight_matches(text, max_length = 200)
    return text if @query.blank? || text.blank?

    # Find the first occurrence of the search term
    query_regex = Regexp.new(Regexp.escape(@query), Regexp::IGNORECASE)
    match_index = text.index(query_regex)
    
    if match_index
      # Extract context around the match
      start_index = [0, match_index - 50].max
      end_index = [text.length, match_index + @query.length + 50].min
      
      excerpt = text[start_index...end_index]
      excerpt = "...#{excerpt}" if start_index > 0
      excerpt = "#{excerpt}..." if end_index < text.length
      
      # Highlight the search term
      excerpt.gsub(query_regex, '<mark>\0</mark>')
    else
      # No match found, return truncated text
      text.length > max_length ? "#{text[0...max_length]}..." : text
    end
  end

  private

  def apply_permission_filter(documents)
    # Apply visibility filtering based on user permissions
    documents.visible_to(@user)
  end

  def apply_search_filter(documents)
    # Use LIKE for case-insensitive search (SQLite is case-insensitive by default)
    search_pattern = "%#{@query}%"
    
    documents.where(
      "title LIKE ? OR content LIKE ? OR excerpt LIKE ?",
      search_pattern, search_pattern, search_pattern
    )
  end

  def apply_filters(documents)
    # Apply folder filter
    if @filters[:folder_id].present?
      folder = Folder.find(@filters[:folder_id])
      folder_ids = [folder.id] + folder.descendant_ids
      documents = documents.where(folder_id: folder_ids)
    end

    # Apply author filter
    if @filters[:author_id].present?
      documents = documents.where(created_by_id: @filters[:author_id])
    end

    # Apply date range filter
    if @filters[:date_from].present?
      documents = documents.where('updated_at >= ?', @filters[:date_from])
    end

    if @filters[:date_to].present?
      documents = documents.where('updated_at <= ?', @filters[:date_to])
    end

    # Apply visibility filter
    if @filters[:visibility].present?
      documents = documents.where(visibility: @filters[:visibility])
    end

    documents
  end

  def apply_sorting_and_limit(documents)
    case @sort_by
    when 'title'
      documents.order(:title).limit(50)
    when 'date_desc'
      documents.order(updated_at: :desc).limit(50)
    when 'date_asc'
      documents.order(updated_at: :asc).limit(50)
    when 'author'
      documents.joins(:created_by).order('users.first_name, users.last_name').limit(50)
    else # 'relevance'
      apply_relevance_ranking(documents)
    end
  end

  def apply_relevance_ranking(documents)
    # Enhanced relevance scoring based on where the match occurs
    # Title matches get highest priority, then excerpt, then content
    documents.order(
      Arel.sql(
        "CASE 
          WHEN title LIKE #{ActiveRecord::Base.connection.quote("%#{@query}%")} THEN 1
          WHEN excerpt LIKE #{ActiveRecord::Base.connection.quote("%#{@query}%")} THEN 2
          WHEN content LIKE #{ActiveRecord::Base.connection.quote("%#{@query}%")} THEN 3
          ELSE 4
        END, 
        CASE 
          WHEN title LIKE #{ActiveRecord::Base.connection.quote("#{@query}%")} THEN 1
          WHEN title LIKE #{ActiveRecord::Base.connection.quote("%#{@query}%")} THEN 2
          ELSE 3
        END,
        updated_at DESC"
      )
    ).limit(50)
  end

  def generate_excerpt(document)
    return document.excerpt if document.excerpt.present?
    
    # Generate excerpt from content
    content = document.content.to_s
    
    if @query.present?
      highlight_matches(content, 300)
    else
      content.length > 300 ? "#{content[0...300]}..." : content
    end
  end

  def calculate_relevance_score(document)
    score = 0
    query_downcase = @query.downcase
    
    # Title match (highest weight)
    if document.title.downcase.include?(query_downcase)
      score += 10
      # Exact title match gets bonus
      score += 5 if document.title.downcase == query_downcase
    end
    
    # Excerpt match (medium weight)
    if document.excerpt.present? && document.excerpt.downcase.include?(query_downcase)
      score += 5
    end
    
    # Content match (lower weight)
    if document.content.downcase.include?(query_downcase)
      score += 2
      # Multiple occurrences get bonus
      occurrences = document.content.downcase.scan(query_downcase).length
      score += [occurrences - 1, 3].min # Cap bonus at 3
    end
    
    # Recent documents get slight bonus
    days_old = (Time.current - document.updated_at) / 1.day
    if days_old < 30
      score += 1
    end
    
    score
  end

  def generate_hierarchy_path(document)
    return "Root" unless document.folder
    
    path_parts = []
    current_folder = document.folder
    
    while current_folder
      path_parts.unshift(current_folder.name)
      current_folder = current_folder.parent
    end
    
    path_parts.join(" / ")
  end
end