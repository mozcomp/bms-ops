class DocumentsController < ApplicationController
  before_action :require_admin_for_modifications, except: [:index, :show]
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_folder, only: [:index, :new, :create]
  before_action :set_breadcrumbs

  def index
    @documents = current_folder_documents.published.visible_to(Current.user).includes(:folder, :created_by)
    @folders = current_folder_subfolders.includes(:documents)
  end

  def show
    unless @document.visible_to?(Current.user)
      redirect_to documents_path, alert: 'Access denied. You do not have permission to view this document.'
      return
    end
    
    # Record the visit for navigation history
    UserDocumentHistory.record_visit(Current.user, @document) if Current.user
    
    @rendered_content = MarkdownRenderer.new(@document.content).to_html
    @breadcrumbs << { name: @document.title, path: nil }
    @is_bookmarked = Current.user&.bookmarked?(@document)
  end

  def new
    @document = Document.new(folder: @folder)
    @breadcrumbs << { name: "New Document", path: nil }
  end

  def create
    @document = Document.new(document_params)
    @document.folder = @folder
    @document.created_by = Current.user
    @document.updated_by = Current.user

    if @document.save
      redirect_to @document, notice: 'Document was successfully created.'
    else
      @breadcrumbs << { name: "New Document", path: nil }
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @breadcrumbs << { name: @document.title, path: document_path(@document) }
    @breadcrumbs << { name: "Edit", path: nil }
  end

  def update
    @document.updated_by = Current.user

    if @document.update(document_params)
      redirect_to @document, notice: 'Document was successfully updated.'
    else
      @breadcrumbs << { name: @document.title, path: document_path(@document) }
      @breadcrumbs << { name: "Edit", path: nil }
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    folder = @document.folder
    @document.destroy
    
    if folder
      redirect_to folder_path(folder), notice: 'Document was successfully deleted.'
    else
      redirect_to documents_path, notice: 'Document was successfully deleted.'
    end
  end

  def search
    @query = params[:q]
    @filters = {
      folder_id: params[:folder_id],
      author_id: params[:author_id],
      date_from: params[:date_from],
      date_to: params[:date_to],
      visibility: params[:visibility]
    }.compact
    @sort_by = params[:sort_by] || 'relevance'
    
    @breadcrumbs = [{ name: "Documentation", path: documents_path }]
    @breadcrumbs << { name: "Search Results", path: nil }
    
    if @query.present?
      search_service = DocumentSearchService.new(@query, Current.user, filters: @filters, sort_by: @sort_by)
      @documents = search_service.search
      @total_results = @documents.count
      @suggestions = search_service.search_suggestions if @documents.empty?
    else
      @documents = Document.none
      @total_results = 0
      @suggestions = []
    end

    # Get filter options for the form
    @folders = Folder.all.order(:name)
    @authors = User.joins(:created_documents).distinct.order(:first_name, :last_name)
  end

  def search_suggestions
    query = params[:q].to_s.strip
    if query.present? && query.length >= 2
      suggestions = DocumentSearchService.new(query, Current.user).search_suggestions
      render json: suggestions
    else
      render json: []
    end
  end

  def toggle_bookmark
    @document = Document.find(params[:id])
    
    unless Current.user
      render json: { error: 'Authentication required' }, status: :unauthorized
      return
    end
    
    bookmarked = UserBookmark.toggle_bookmark(Current.user, @document)
    
    render json: { 
      bookmarked: bookmarked,
      message: bookmarked ? 'Document bookmarked' : 'Bookmark removed'
    }
  end

  def recent
    @breadcrumbs = [{ name: "Documentation", path: documents_path }]
    @breadcrumbs << { name: "Recently Viewed", path: nil }
    
    if Current.user
      @documents = Current.user.recent_documents(20)
    else
      @documents = []
    end
  end

  def bookmarks
    @breadcrumbs = [{ name: "Documentation", path: documents_path }]
    @breadcrumbs << { name: "Bookmarks", path: nil }
    
    if Current.user
      @documents = Current.user.bookmarked_documents.published.visible_to(Current.user)
                              .includes(:folder, :created_by)
                              .joins(:user_bookmarks)
                              .order('user_bookmarks.bookmarked_at DESC')
    else
      @documents = []
    end
  end
  
  def upload_attachment
    @document = Document.find(params[:id])
    
    unless Current.user&.admin?
      render json: { error: 'Access denied' }, status: :forbidden
      return
    end
    
    if params[:attachment].present?
      @document.attachments.attach(params[:attachment])
      
      if @document.valid?
        attachment = @document.attachments.last
        markdown_reference = @document.attachment_markdown_reference(attachment)
        
        render json: {
          success: true,
          filename: attachment.filename.to_s,
          markdown: markdown_reference,
          url: rails_blob_path(attachment, only_path: true)
        }
      else
        render json: { 
          error: @document.errors.full_messages.join(', ') 
        }, status: :unprocessable_entity
      end
    else
      render json: { error: 'No file provided' }, status: :bad_request
    end
  end
  
  def versions
    @document = Document.find(params[:id])
    @versions = @document.document_versions.includes(:created_by).ordered
    @breadcrumbs << { name: @document.title, path: document_path(@document) }
    @breadcrumbs << { name: "Version History", path: nil }
  end
  
  def compare_versions
    @document = Document.find(params[:id])
    @version1 = @document.document_versions.find(params[:version1_id]) if params[:version1_id].present?
    @version2 = @document.document_versions.find(params[:version2_id]) if params[:version2_id].present?
    
    # Default to current version if no version2 specified
    @version2_content = @version2 ? @version2.content : @document.content
    @version1_content = @version1 ? @version1.content : ""
    
    @breadcrumbs << { name: @document.title, path: document_path(@document) }
    @breadcrumbs << { name: "Version History", path: versions_document_path(@document) }
    @breadcrumbs << { name: "Compare Versions", path: nil }
  end
  
  def restore_version
    @document = Document.find(params[:id])
    @version = @document.document_versions.find(params[:version_id])
    
    unless Current.user&.admin?
      redirect_to document_path(@document), alert: 'Access denied. Administrator privileges required.'
      return
    end
    
    # Update document content with version content
    @document.content = @version.content
    @document.updated_by = Current.user
    
    if @document.save
      redirect_to document_path(@document), notice: "Document restored to version #{@version.version_number}."
    else
      redirect_to versions_document_path(@document), alert: 'Failed to restore version.'
    end
  end

  private

  def require_admin_for_modifications
    unless Current.user&.admin?
      redirect_to documents_path, alert: 'Access denied. Administrator privileges required.'
    end
  end

  def set_document
    @document = Document.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to documents_path, alert: 'Document not found.'
  end

  def set_folder
    @folder = params[:folder_id] ? Folder.find(params[:folder_id]) : nil
  rescue ActiveRecord::RecordNotFound
    redirect_to documents_path, alert: 'Folder not found.'
  end

  def set_breadcrumbs
    @breadcrumbs = [{ name: "Documentation", path: documents_path }]
    
    if @folder
      @folder.ancestors.each do |ancestor|
        @breadcrumbs << { name: ancestor.name, path: folder_path(ancestor) }
      end
      @breadcrumbs << { name: @folder.name, path: folder_path(@folder) }
    elsif @document&.folder
      @document.folder.ancestors.each do |ancestor|
        @breadcrumbs << { name: ancestor.name, path: folder_path(ancestor) }
      end
      @breadcrumbs << { name: @document.folder.name, path: folder_path(@document.folder) }
    end
  end

  def current_folder_documents
    if @folder
      @folder.documents
    else
      Document.where(folder: nil)
    end
  end

  def current_folder_subfolders
    if @folder
      @folder.children
    else
      Folder.root_folders
    end
  end

  def document_params
    params.require(:document).permit(:title, :content, :excerpt, :published, :visibility, attachments: [])
  end
end