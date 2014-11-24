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

    describe "Basics" do

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

      it "counts the collection" do
        assert_equal 0, Chef.count
      end
    end

    describe "Persistence" do

      before do
        Chef.delete_all
      end

      it "should save a new model" do
        chef = Chef.new name: "Alfredo", speciality: "Asado"

        assert chef.new?
        assert chef.save
        assert_equal 1, Chef.count
        refute chef.new?
      end

      it "creates a new model with a hash" do
        chef = Chef.create name: "Mariana", speciality: "Pastas"
        assert_equal "Mariana", chef.name
        assert_equal "Pastas", chef.speciality
      end

      it "modifies attributes" do
        chef = Chef.create name: "Juan"
        chef.name = "Roberto"
        chef.save
        assert_equal "Roberto", chef.name
      end

      it "finds by id" do
        chef = Chef.create name: "Homer"
        assert_equal "Homer", Chef[chef.id].name
      end

      it "should return nil if the record is not found" do
        assert_nil Chef[100]
      end

      it "destroys a record" do
        chef = Chef.create
        assert chef.id

        chef.destroy
        assert_nil Chef[chef.id]
      end
    end
  end
end

