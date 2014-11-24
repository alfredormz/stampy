require "minitest/autorun"
require "stampy"

Stampy.connect

begin
  Stampy.database.execute("DROP TABLE chef")
rescue
end

class Chef < Stampy::Model
end

describe Stampy do

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
    assert_equal 1, Stampy.database.execute(query)
  end
end
