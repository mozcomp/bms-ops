namespace :ops do
  desc "import existing AWS services into BMS Ops"
  task import_resources: :environment do
    Resources.new.services.each do |service|
      puts "Importing service: #{service.service_name}"
      svc = Service.find_or_initialize_by(name: service.service_name)
      svc.image = service.settings[:image]
      svc.version = service.settings[:version]
      svc.registry = service.registry
      svc.service_definition = service.settings[:service_definition]
      svc.service_task = service.settings[:service_task]
      svc.task_definitions = service.settings[:task_definitions]
      svc.environment = service.settings[:environment]
      if svc.save
        puts "  Imported successfully."
      else
        puts "  Failed to import: #{svc.errors.full_messages.join(', ')}"
      end
      app = App.find_or_initialize_by(name: service.settings[:image])
      app.repository = "https://github.com/ambit/#{service.settings[:image]}.git"
      if app.save
        puts "  Associated application saved successfully."
      else
        puts "  Failed to save associated application: #{app.errors.full_messages.join(', ')}"
      end
    end
  end

  desc "import existing tenants & database from BMS Domains into BMS Ops"
  task import_tenants: :environment do
    Domain.all.each do |domain|
      puts "Importing tenant: #{domain.name}"
      tenant = Tenant.find_or_initialize_by(name: domain.name)
      tenant.domain = domain.name
      tenant.database_config = domain.database_config
      if tenant.save
        puts "  Imported successfully."
      else
        puts "  Failed to import: #{tenant.errors.full_messages.join(', ')}"
      end
    end
  end
end
