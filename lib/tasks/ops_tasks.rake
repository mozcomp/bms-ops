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
    Instance.delete_all
    Tenant.delete_all
    Domain.all.each do |domain|
      puts "Importing tenant: #{domain.name}"
      if match = domain.code.downcase.match(/(.+)-staging/)
        code = match[1]
        env = 'staging'
      elsif match = domain.code.downcase.match(/(.+)-development/)
        code = match[1]
        env = 'development'
      elsif match = domain.code.downcase.match(/(.+)-dev/)
        code = match[1]
        env = 'development'
      elsif match = domain.code.downcase.match(/(.+)-demo/)
        code = match[1]
        env = 'staging'
      elsif match = domain.code.downcase.match(/(.+)-local/)
        code = match[1]
        env = 'development'
      else
        code = domain.code.downcase
        env = 'production'
      end
      tenant = Tenant.find_or_create_by(code: code) do |t|
        t.name = domain.name
      end
      puts "tenant_code: #{code}, tenant: #{tenant.inspect}, env: #{env}"
      instance = Instance.find_or_initialize_by(name: domain.s3_bucket)
      instance.tenant = tenant
      instance.app = App.find_by(name: 'bms-cloud')
      instance.service = Service.find_by(name: domain.service_name)
      instance.environment = env
      file = File.new("/Users/mozcomp/Projects/bms-cli/resources/env/#{domain.s3_bucket}.env") rescue nil
      if file.present?
        env_vars = YAML.load_file(file)
        instance.env_vars = env_vars.split
      else
        instance.env_vars = []
      end
      instance.save
      if instance.save
        puts "  Imported successfully."
      else
        puts "  Failed to import: #{instance
        .errors.full_messages.join(', ')}"
      end
    end
  end
end
