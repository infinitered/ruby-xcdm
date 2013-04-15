
require 'test/unit'
require 'schema'

class SchemaTest < Test::Unit::TestCase

  def test_initialize
    s = Schema.new("0.0.1")
    assert_equal "0.0.1", s.version
  end

  def test_entity
    s = Schema.new("0.0.1")
    e = s.entity("MyType") { |e| assert e.is_a?(Entity) }
    assert e.is_a?(Entity)
  end


end
