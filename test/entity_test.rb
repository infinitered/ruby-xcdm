
require 'test/unit'
require 'entity'

class EntityTest < Test::Unit::TestCase

  def e
    @e ||= Entity.new("MyTest") 
  end

  def test_initialize
    assert_equal "MyTest", e.name
  end

  def test_raw_property
    opts = { propertyType: "Integer 32", name: 'foobar' }
    e.raw_property(opts)
    assert_equal [opts.merge(optional: 'YES', syncable: 'YES')], e.properties
  end

  def test_property_integer32
    e.property('foobar', :integer32, optional: false)
    assert_equal [{ optional: 'NO', syncable: 'YES', propertyType: "Integer 32", name: 'foobar' }], e.properties
  end

  def test_property_datetime
    e.property('fazbit', :datetime, optional: false)
    assert_equal [{ optional: 'NO', syncable: 'YES', propertyType: "Date", name: 'fazbit' }], e.properties
  end

  def test_property_short_form_string
    e.string 'frobnoz', optional: false
    assert_equal [{ optional: 'NO', syncable: 'YES', propertyType: "String", name: 'frobnoz' }], e.properties
  end

  def test_convert_type
    assert_equal 'Integer 16',    Entity.convert_type(:integer16)
    assert_equal 'Integer 32',    Entity.convert_type(:integer32)
    assert_equal 'Integer 64',    Entity.convert_type(:integer64)
    assert_equal 'Decimal',       Entity.convert_type(:decimal)
    assert_equal 'Double',        Entity.convert_type(:double)
    assert_equal 'Float',         Entity.convert_type(:float)
    assert_equal 'String',        Entity.convert_type(:string)
    assert_equal 'Boolean',       Entity.convert_type(:boolean)
    assert_equal 'Date',          Entity.convert_type(:datetime)
    assert_equal 'Binary Data',   Entity.convert_type(:binary)
    assert_equal 'Transformable', Entity.convert_type(:transformable)
  end

end
