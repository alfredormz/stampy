require 'sequel'

Sequel.extension :pg_hstore, :pg_hstore_ops

module Stampy

  def self.connect(url=nil)
    @url      = url || ENV['DATABASE_URL']

    @database = Sequel.connect(@url).tap do |db|
      db.execute "CREATE EXTENSION IF NOT EXISTS HSTORE"
    end
  end

  def self.database
    @database
  end

  def self.execute(query)
    database.execute query
  end

  class Model

    def initialize(attrs={})
      @attributes = {}
      attrs.each do |key, value|
        public_send "#{key}=", value
      end
    end

    def self.count
      table.count
    end

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

    def self.table
      database[table_name.to_sym]
    end

    def self.attribute(*attrs)
      attrs.each do |attr|
        define_method attr do
          @attributes[attr]
        end

        define_method :"#{attr}=" do |value|
          @attributes[attr] = value
        end
      end
    end
  end
end
