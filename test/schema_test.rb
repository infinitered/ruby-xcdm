require 'minitest/autorun'
require 'xcdm/entity'
require 'xcdm/schema'
require 'rexml/document'
require 'active_support/all'

module XCDM
  class SchemaTest < Minitest::Test

    def test_initialize
      s = Schema.new("0.0.1", "4.6")
      assert_equal "0.0.1", s.version
      assert_equal "4.6", s.xcode_version
    end

    def test_entity
      s = Schema.new("0.0.1", "4.6")
      entity = nil
      s.entity("MyType") { entity = self; nil }
      assert entity.is_a?(Entity), "Block should be executed in context of the new entity" 
      assert_equal [entity], s.entities
    end

    def test_loader
      fixture = File.join(File.dirname(__FILE__), 'fixtures', '001_baseline.rb')

      loader = Schema::Loader.new("4.6")
      schema = loader.load_file(fixture)
      assert_equal schema.nil?, false
      assert_equal '0.0.1', schema.version
      assert_equal schema, loader.schemas.first
      assert_equal ['Article', 'Author'], schema.entities.map(&:name)
    end

    def test_to_xml
      in_fixture = File.join(File.dirname(__FILE__), 'fixtures', '001_baseline.rb')
      loader = Schema::Loader.new("4.6")
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
