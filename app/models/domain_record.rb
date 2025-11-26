  class DomainRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: { writing: :domains }
  end
