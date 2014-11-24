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
  end
end
