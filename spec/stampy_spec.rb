require "minitest/autorun"
require "stampy"

class Chef < Stampy::Model
end

describe Stampy do

  it "should be connect to a pg database" do
    Stampy.connect
    assert_equal Sequel::Postgres::Database, Stampy.database.class
  end
end
