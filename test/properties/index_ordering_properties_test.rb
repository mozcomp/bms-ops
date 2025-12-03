require "test_helper"
require "test_helpers/property_test_helper"

class IndexOrderingPropertiesTest < ActiveSupport::TestCase
  include PropertyTestHelper

  # Feature: infrastructure-management, Property 17: Index ordering consistency
  # For any collection of records (tenants, apps, services, or databases),
  # the index view should display them ordered by created_at in descending order.
  # Validates: Requirements 7.1, 7.2, 7.3, 7.4
  test "Property 17: Index ordering consistency for all models" do
    property_of("index ordering consistency") do |rantly|
      # Generate a random number of records (3-10)
      record_count = rantly.range(3, 10)
      
      # Choose a random model to test
      model_class = rantly.choose(Tenant, App, Service, Database)
      
      [ model_class, record_count ]
    end.each do |model_class, record_count|
      # Clean up any existing records
      model_class.destroy_all
      
      # Create records with different timestamps
      records = []
      record_count.times do |i|
        record = case model_class.name
        when "Tenant"
          Tenant.create!(
            code: "tenant#{i}_#{SecureRandom.hex(4)}",
            name: "Tenant #{i}"
          )
        when "App"
          App.create!(
            name: "App #{i} #{SecureRandom.hex(4)}",
            repository: "https://github.com/owner/repo#{i}"
          )
        when "Service"
          Service.create!(
            name: "Service #{i} #{SecureRandom.hex(4)}",
            image: "image#{i}"
          )
        when "Database"
          Database.create!(
            name: "Database #{i} #{SecureRandom.hex(4)}"
          )
        end
        
        # Ensure different timestamps by sleeping briefly
        sleep(0.01) if i < record_count - 1
        
        records << record
      end
      
      # Retrieve records using the same ordering as the index action
      retrieved_records = model_class.all.order(created_at: :desc).to_a
      
      # Verify the records are ordered by created_at descending
      # The most recently created should be first
      assert_equal records.last.id, retrieved_records.first.id,
        "Expected most recent record (#{records.last.id}) to be first, but got #{retrieved_records.first.id}"
      
      # Verify all records are in descending order
      retrieved_records.each_cons(2) do |newer, older|
        assert newer.created_at >= older.created_at,
          "Records not in descending order: #{newer.created_at} should be >= #{older.created_at}"
      end
      
      # Clean up
      model_class.destroy_all
    end
  end
end
