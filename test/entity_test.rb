require 'minitest/autorun'
require 'xcdm/entity'
require 'xcdm/schema'
require 'rexml/document'

module XCDM
  class EntityTest < Minitest::Test

    attr_reader :e, :pub

    def setup
      s = XCDM::Schema.new("0.0.1", "4.6")
      @pub ||= Entity.new(s, "Publication", abstract: true)
      @e ||= Entity.new(s, "Article", parent: "Publication")
    end

    def test_initialize
      assert_equal "Article", e.name
    end

    def test_raw_property
      opts = { attributeType: "Integer 32", name: 'foobar' }
      e.raw_property(opts)
      assert_equal [opts.merge(optional: 'YES', syncable: 'YES')], e.properties
    end

    def test_property_integer32
      e.property 'foobar', :integer32, optional: false
      assert_equal [{ optional: 'NO', syncable: 'YES', attributeType: 'Integer 32', name: 'foobar', defaultValueString: "0" }], e.properties
    end

    def test_property_datetime
      e.property 'fazbit', :datetime, optional: false
      assert_equal [{ optional: 'NO', syncable: 'YES', attributeType: 'Date', name: 'fazbit' }], e.properties
    end

    def test_property_short_form_string
      e.string 'frobnoz', optional: false
      assert_equal [{ optional: 'NO', syncable: 'YES', attributeType: 'String', name: 'frobnoz' }], e.properties
    end

    def test_property_default
      e.integer32 'count', default: 1
      assert_equal [{ optional: 'YES', syncable: 'YES', attributeType: 'Integer 32', name: 'count', defaultValueString: '1' }], e.properties
    end

    def test_property_default_nil
      e.integer32 'count', default: nil
      assert_equal [{ optional: 'YES', syncable: 'YES', attributeType: 'Integer 32', name: 'count' }], e.properties
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
      assert_equal 'Binary',        Entity.convert_type(:binary)
      assert_equal 'Transformable', Entity.convert_type(:transformable)
    end

    def test_parent_entity
      assert_equal 'Publication', e.parent
    end

    def test_abstract_entity
      assert pub.abstract
    end

    def test_raw_relationship
      opts = { name: "author", minCount: "1", maxCount: "1", destinationEntity: "Author", inverseName: "articles", inverseEntity: "Author" }
      e.raw_relationship(opts)
      assert_equal [opts.merge(optional: "YES", deletionRule: "Nullify", syncable: "YES")], e.relationships
    end

    def test_relationship
      e.relationship('author', maxCount: 1, minCount: 1)
      assert_equal [{ optional: "YES", deletionRule: "Nullify", syncable: "YES",
                      name: "author", minCount: "1", maxCount: "1", destinationEntity:
                      "Author", inverseName: "article", inverseEntity: "Author" }], e.relationships
    end

    def test_has_one
      e.has_one 'author'
      assert_equal [{ optional: "YES", deletionRule: "Nullify", syncable: "YES",
                      name: "author", minCount: "1", maxCount: "1", destinationEntity:
                      "Author", inverseName: "article", inverseEntity: "Author" }], e.relationships
    end

    def test_has_one_should_not_plural
      e.has_one 'address'
      assert_equal [{ optional: "YES", deletionRule: "Nullify", syncable: "YES",
                      name: "address", minCount: "1", maxCount: "1", destinationEntity:
                      "Address", inverseName: "article", inverseEntity: "Address" }], e.relationships
    end

    def test_belongs_to
      e.belongs_to 'author'
      assert_equal [{ optional: "YES", deletionRule: "Nullify", syncable: "YES",
                      name: "author", minCount: "1", maxCount: "1", destinationEntity:
                      "Author", inverseName: "articles", inverseEntity: "Author" }], e.relationships
    end

    def test_has_many
      e.has_many 'authors'
      assert_equal [{ optional: "YES", deletionRule: "Nullify", syncable: "YES",
                      name: "authors", minCount: "1", maxCount: "-1", destinationEntity:
                      "Author", inverseName: "article", inverseEntity: "Author" }], e.relationships
    end

    def test_deletion_cascade
      e.has_many 'authors', { deletionRule: 'Cascade'}
      assert_equal [{ optional: "YES", deletionRule: "Cascade", syncable: "YES",
                      name: "authors", minCount: "1", maxCount: "-1", destinationEntity:
                      "Author", inverseName: "article", inverseEntity: "Author" }], e.relationships
    end

    def test_non_inferrable_relationship_with_inverse
      e.belongs_to 'primary_author', inverse: 'Author.primary_articles'
      assert_equal [{ optional: "YES", deletionRule: "Nullify", syncable: "YES",
                      name: "primary_author", minCount: "1", maxCount: "1", destinationEntity:
                      "Author", inverseName: "primary_articles", inverseEntity: "Author" }], e.relationships
    end

    def test_to_xml
      expected = REXML::Document.new %{
<entity name="Article" representedClassName="Article" parentEntity="Publication" syncable="YES">
  <attribute name="body" optional="NO" attributeType="String" syncable="YES">
  </attribute>
  <attribute name="length" optional="YES" attributeType="Integer 32" defaultValueString="0" syncable="YES">
  </attribute>
  <attribute name="published" optional="YES" attributeType="Boolean" defaultValueString="NO" syncable="YES">
  </attribute>
  <attribute name="publishedAt" optional="YES" attributeType="Date" defaultValueString="NO" syncable="YES">
  </attribute>
  <attribute name="title" optional="NO" attributeType="String" syncable="YES">
  </attribute>
  <relationship name="author" optional="YES" minCount="1" maxCount="1" deletionRule="Nullify" destinationEntity="Author" inverseName="articles" inverseEntity="Author" syncable="YES">
  </relationship>
</entity>
      }

      e.string    :body,        optional: false
      e.integer32 :length
      e.boolean   :published,   default: false
      e.datetime  :publishedAt, default: false
      e.string    :title,       optional: false

      e.belongs_to   :author

      assert_equal expected.to_s.strip, REXML::Document.new(e.to_xml).to_s.strip

      expected = REXML::Document.new %{
<entity name="Publication" representedClassName="Publication" isAbstract="YES" syncable="YES">
</entity>
      }

      assert_equal expected.to_s.strip, REXML::Document.new(pub.to_xml).to_s.strip
    end

  end
end
