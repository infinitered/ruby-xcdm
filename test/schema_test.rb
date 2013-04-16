
require 'test/unit'
require 'schema'

class SchemaTest < Test::Unit::TestCase

  def test_initialize
    s = Schema.new("0.0.1")
    assert_equal "0.0.1", s.version
  end

  def test_entity
    s = Schema.new("0.0.1")
    entity = nil
    s.entity("MyType") { entity = self; nil }
    assert entity.is_a?(Entity), "Block should be executed in context of the new entity" 
    assert_equal [entity], s.entities
  end


  def test_loader
    fixture = File.join(File.dirname(__FILE__), 'fixtures', '001_baseline.rb')
    
    loader = Schema::Loader.new
    schema = loader.load_file(fixture)
    assert_not_nil schema
    assert_equal '0.0.1', schema.version
    assert_equal ['Article', 'Author'], schema.entities.map(&:name)
  end


end
