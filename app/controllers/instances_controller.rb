class InstancesController < ApplicationController
  before_action :set_instance, only: [ :show, :edit, :update, :destroy ]

  def index
    @instances = Instance.includes(:tenant, :app, :service).order(created_at: :desc)

    # Filter by tenant if tenant_id param is present
    if params[:tenant_id].present?
      @instances = @instances.where(tenant_id: params[:tenant_id])
    end

    # Filter by environment if environment param is present
    if params[:environment].present?
      @instances = @instances.where(environment: params[:environment])
    end

    # Filter by service if service_id param is present
    if params[:service_id].present?
      @instances = @instances.where(service_id: params[:service_id])
    end
  end

  def show
  end

  def new
    @instance = Instance.new
    load_form_data
  end

  def edit
    load_form_data
  end

  def create
    @instance = Instance.new(instance_params)

    if @instance.save
      redirect_to @instance, notice: "Instance was successfully created."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @instance.update(instance_params)
      redirect_to @instance, notice: "Instance was successfully updated."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @instance.destroy!
    redirect_to instances_path, notice: "Instance was successfully deleted."
  end

  private

  def set_instance
    @instance = Instance.includes(:tenant, :app, :service).find(params[:id])
  end

  def load_form_data
    @tenants = Tenant.all.order(:name)
    @apps = App.all.order(:name)
    @services = Service.all.order(:name)
  end

  def instance_params
    params.require(:instance).permit(:name, :tenant_id, :app_id, :service_id, :environment, :virtual_host, :env_vars_json)
  end
end
