class DatabasesController < ApplicationController
  before_action :set_database, only: [ :show, :edit, :update, :destroy ]

  def index
    @databases = Database.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @database = Database.new
  end

  def edit
  end

  def create
    @database = Database.new(database_params)

    if @database.save
      redirect_to @database, notice: "Database was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @database.update(database_params)
      redirect_to @database, notice: "Database was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @database.destroy!
    redirect_to databases_path, notice: "Database was successfully deleted."
  end

  private

  def set_database
    @database = Database.find(params[:id])
  end

  def database_params
    params.require(:database).permit(:name, :schema_version, :connection_json)
  end
end
