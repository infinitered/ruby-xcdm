
require 'test/unit'
require 'xcdm/schema'
require 'rexml/document'
require 'active_support/all'

module XCDM
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
      assert_equal schema, loader.schemas.first
      assert_equal ['Article', 'Author'], schema.entities.map(&:name)
    end

    def test_to_xml
      in_fixture = File.join(File.dirname(__FILE__), 'fixtures', '001_baseline.rb')
      loader = Schema::Loader.new
      schema = loader.load_file(in_fixture)

      out_fixture = File.join(File.dirname(__FILE__), 'fixtures', 'Article.xcdatamodeld', 'Article.xcdatamodel', 'contents')

      inlines = REXML::Document.new(File.read(out_fixture)).to_s.split("\n").map(&:strip)
      outlines = REXML::Document.new(schema.to_xml).to_s.split("\n").map(&:strip)
      inlines.each_with_index do |line, i|
        assert_equal line, outlines[i]
      end

    end

  end
end
