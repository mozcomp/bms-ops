class AppsController < ApplicationController
  before_action :set_app, only: [ :show, :edit, :update, :destroy ]

  def index
    @apps = App.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @app = App.new
  end

  def edit
  end

  def create
    @app = App.new(app_params)

    if @app.save
      redirect_to @app, notice: "App was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @app.update(app_params)
      redirect_to @app, notice: "App was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @app.destroy!
    redirect_to apps_path, notice: "App was successfully deleted."
  end

  private

  def set_app
    @app = App.find(params[:id])
  end

  def app_params
    params.require(:app).permit(:name, :repository)
  end
end
