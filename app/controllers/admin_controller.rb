class AdminController < ApplicationController
  before_action :require_admin
  before_action :set_breadcrumbs

  def index
    @users_count = User.count
    @documents_count = Document.count
    @admin_users_count = User.where(admin: true).count
    @recent_documents = Document.includes(:created_by, :updated_by).order(updated_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
  end

  def users
    @users = User.includes(:created_documents, :updated_documents).order(:first_name, :last_name, :email_address)
    @breadcrumbs << { name: "User Management", path: nil }
  end

  def update_user_admin
    @user = User.find(params[:id])
    
    if @user.update(admin: params[:admin] == 'true')
      action = params[:admin] == 'true' ? 'granted' : 'revoked'
      redirect_to admin_users_path, notice: "Administrator privileges #{action} for #{@user.full_name}."
    else
      redirect_to admin_users_path, alert: 'Failed to update user permissions.'
    end
  end

  def documents
    @documents = Document.includes(:created_by, :updated_by, :folder)
                        .order(:visibility, :title)
    @breadcrumbs << { name: "Document Management", path: nil }
    
    # Filter by visibility if specified
    if params[:visibility].present? && %w[public private admin_only].include?(params[:visibility])
      @documents = @documents.where(visibility: params[:visibility])
    end
  end

  def update_document_visibility
    @document = Document.find(params[:id])
    
    if @document.update(visibility: params[:visibility])
      redirect_to admin_documents_path, notice: "Document visibility updated to #{params[:visibility].humanize.downcase}."
    else
      redirect_to admin_documents_path, alert: 'Failed to update document visibility.'
    end
  end

  private

  def require_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: 'Access denied. Administrator privileges required.'
    end
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { name: "Documentation", path: documents_path },
      { name: "Administration", path: admin_path }
    ]
  end
end