require 'sequel'

Sequel.extension :pg_hstore, :pg_hstore_ops

module Stampy

  def self.connect(url=nil)
    @url      = url || ENV['DATABASE_URL']
    @database = Sequel.connect(@url)
  end

  def self.database
    @database
  end

  class Model

    def self.table_name
      self.name.downcase
    end

    def self.inherited(model)
      self.database.create_table? model.table_name do
        primary_key :id
        hstore      :data
      end
    end

    def self.database
      Stampy.database
    end
  end
end
