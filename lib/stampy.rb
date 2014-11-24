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

    attr_reader :id

    def initialize(attrs={})
      @attributes = {}
      update_attributes attrs
    end

    def new?
      @id.nil?
    end

    def save
      if new?
        create @attributes
      else
        update
      end
    end

    def create(attrs={})
      @id = table.insert(
        data: Sequel.hstore(@attributes)
      )
    end

    def update
      table[id: @id].update(
        data: Sequel.hstore(@attributes)
      )
    end

    def self.create(attrs={})
      instance = new(attrs)
      instance.save
      instance
    end

    def table
      self.class.table
    end

    def update_attributes(attrs={})
      @id = attrs.delete(:id)
      attrs.each do |key, value|
        public_send "#{key}=", value
      end
    end

    def self.[](id)
      new(id: id).load!
    end

    def load!
      record = table[id: @id]
      return if record.nil?

      @id         = record[:id]
      @attributes = record[:data]

      self
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

    def self.truncate
      table.truncate
    end

    def self.delete_all
      table.delete
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
