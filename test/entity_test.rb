
require 'test/unit'
require 'entity'

class EntityTest < Test::Unit::TestCase

  def test_initialize
    e = Entity.new("MyTest")
    assert_equal "MyTest", e.name
  end

  def test_raw_attribute
    e = Entity.new("MyTest")
    opts = { attributeType: "Integer 32", name: 'foobar' }
    e.raw_attribute(opts)
    assert_equal [opts.merge(optional: 'YES', syncable: 'YES')], e.attributes
  end

end
