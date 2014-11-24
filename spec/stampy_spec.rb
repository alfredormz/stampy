require "minitest/autorun"
require "stampy"

Stampy.connect

begin
  Stampy.execute("DROP TABLE chef")
rescue
end

class Chef < Stampy::Model
  attribute :name, :speciality
end

describe Stampy do

  describe "Module functions" do
    it "should be connect to a pg database" do
      assert_equal Sequel::Postgres::Database, Stampy.database.class
    end

    it "#table_name" do
      assert_equal "chef", Chef.table_name
    end

    it "should create the table if does not exist" do
      query = %q{
  SELECT 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  n.nspname = 'public'
  AND    c.relname = 'chef'
  AND    c.relkind = 'r'
      }
      assert_equal 1, Stampy.execute(query)
    end
  end

  describe Stampy::Model do

    let(:carl) { Chef.new }

    it "should create accessors for each attribute" do
      %i{name speciality}.each do |method|
        assert carl.respond_to?(method), "carl.#{method} should exist"
 
        writer_method = :"#{method}="
        assert carl.respond_to?(writer_method), "carl.#{writer_method} does not exist"
      end
    end

    it "should store the values" do
       carl.name = "Carl Casper"
       assert_equal "Carl Casper", carl.name

       carl.speciality = "Sandwich Cubano"
       assert_equal "Sandwich Cubano", carl.speciality
    end

    it "initializes with a hash" do
      martin = Chef.new name: "Martin", speciality: "Arroz con Pollo"
      assert_equal "Martin", martin.name
      assert_equal "Arroz con Pollo", martin.speciality
    end
  end
end

