class Tenants::InstancesController < ApplicationController
  before_action :set_tenant

  def new
    @instance = @tenant.instances.build
    load_form_data
    
    # Pre-select bms-cloud app if it exists, or use first available app for testing
    @bms_cloud_app = App.find_by(name: 'bms-cloud') || App.first
    @instance.app = @bms_cloud_app if @bms_cloud_app
  end

  def create
    @instance = @tenant.instances.build(instance_params)
    
    # Set the bms-cloud app if not already set, or use the first available app for testing
    @instance.app ||= App.find_by(name: 'bms-cloud') || App.first
    @instance.name = "bms-#{@tenant.code}-#{@instance.environment}"
    @instance.virtual_host = "#{@tenant.code}"
    @instance.virtual_host += "-#{@instance.environment}" unless @instance.environment == 'production'
    @instance.virtual_host += ".bmserp.com"

    if @instance.save
      redirect_to @tenant, notice: "Instance was successfully created for #{@tenant.name}."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end

  def load_form_data
    @services = Service.all.order(:name)
    @environments = %w[production staging development]
  end

  def instance_params
    params.require(:instance).permit(:service_id, :environment)
  end
end