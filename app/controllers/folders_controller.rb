class FoldersController < ApplicationController
  before_action :require_admin, except: [:index, :show]
  before_action :set_folder, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_folder, only: [:new, :create]
  before_action :set_breadcrumbs

  def index
    @root_folders = Folder.root_folders.includes(:children, :documents)
    @root_documents = Document.where(folder: nil).published.includes(:created_by)
  end

  def show
    @documents = @folder.documents.published.includes(:created_by)
    @subfolders = @folder.children.includes(:documents)
    @document_count = @documents.count
    @subfolder_count = @subfolders.count
    @breadcrumbs << { name: @folder.name, path: nil }
  end

  def new
    @folder = Folder.new(parent: @parent_folder)
    breadcrumb_name = @parent_folder ? "New Subfolder" : "New Folder"
    @breadcrumbs << { name: breadcrumb_name, path: nil }
  end

  def create
    @folder = Folder.new(folder_params)
    @folder.parent = @parent_folder
    @folder.created_by = Current.user

    if @folder.save
      redirect_to @folder, notice: 'Folder was successfully created.'
    else
      breadcrumb_name = @parent_folder ? "New Subfolder" : "New Folder"
      @breadcrumbs << { name: breadcrumb_name, path: nil }
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @breadcrumbs << { name: @folder.name, path: folder_path(@folder) }
    @breadcrumbs << { name: "Edit", path: nil }
  end

  def update
    if @folder.update(folder_params)
      redirect_to @folder, notice: 'Folder was successfully updated.'
    else
      @breadcrumbs << { name: @folder.name, path: folder_path(@folder) }
      @breadcrumbs << { name: "Edit", path: nil }
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Check if folder contains documents or subfolders
    if @folder.documents.exists? || @folder.children.exists?
      redirect_to @folder, alert: 'Cannot delete folder that contains documents or subfolders.'
      return
    end

    parent = @folder.parent
    @folder.destroy

    if parent
      redirect_to folder_path(parent), notice: 'Folder was successfully deleted.'
    else
      redirect_to folders_path, notice: 'Folder was successfully deleted.'
    end
  end

  private

  def require_admin
    unless Current.user&.admin?
      redirect_to folders_path, alert: 'Access denied. Administrator privileges required.'
    end
  end

  def set_folder
    @folder = Folder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to folders_path, alert: 'Folder not found.'
  end

  def set_parent_folder
    @parent_folder = params[:parent_id] ? Folder.find(params[:parent_id]) : nil
  rescue ActiveRecord::RecordNotFound
    redirect_to folders_path, alert: 'Parent folder not found.'
  end

  def set_breadcrumbs
    @breadcrumbs = [{ name: "Documentation", path: folders_path }]
    
    if @parent_folder
      @parent_folder.ancestors.each do |ancestor|
        @breadcrumbs << { name: ancestor.name, path: folder_path(ancestor) }
      end
      @breadcrumbs << { name: @parent_folder.name, path: folder_path(@parent_folder) }
    elsif @folder
      @folder.ancestors.each do |ancestor|
        @breadcrumbs << { name: ancestor.name, path: folder_path(ancestor) }
      end
    end
  end

  def folder_params
    params.require(:folder).permit(:name, :description)
  end
end