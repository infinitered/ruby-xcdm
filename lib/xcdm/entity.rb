
require 'active_support/all'
require 'builder'

module XCDM
  class Entity

    DEFAULT_PROPERTY_ATTRIBUTES = { optional: 'YES', syncable: 'YES' }

    DEFAULT_RELATIONSHIP_ATTRIBUTES = { optional: 'YES', deletionRule: 'Nullify', syncable: 'YES' }

    TYPE_MAPPING = {
      integer16:     'Integer 16',
      integer32:     'Integer 32',
      integer64:     'Integer 64',
      decimal:       'Decimal',
      double:        'Double',
      float:         'Float',
      string:        'String',
      boolean:       'Boolean',
      datetime:      'Date',
      binary:        'Binary Data',
      transformable: 'Transformable'
    }


    attr_reader :name, :properties, :relationships


    def initialize(name, options = {})
      @name = name
      @properties = []
      @relationships = []
    end

    def raw_property(options)
      @properties << DEFAULT_PROPERTY_ATTRIBUTES.merge(options)
    end

    def property(name, type, options = {})
      property = {}

      property[:attributeType] = self.class.convert_type(type)
      property[:name] = name.to_s

      if !options[:default].nil?
        property[:defaultValueString] = normalize_value(options.delete(:default))
      elsif [:integer16, :integer32, :integer64].include?(type)
        property[:defaultValueString] = "0"
      elsif [:float, :double, :decimal].include?(type)
        property[:defaultValueString] = "0.0"
      end

      normalize_values(options, property)
      raw_property(property)
    end

    # Make shortcut property methods for each data type
    TYPE_MAPPING.keys.each do |type|
      define_method(type) do |name, options = {}|
        property(name, type, options)
      end
    end


    def raw_relationship(options)
      @relationships << DEFAULT_RELATIONSHIP_ATTRIBUTES.merge(options)
    end

    def relationship(name, options = {})
      relationship = {}
      relationship[:name] = name.to_s
      if options[:inverse]
        entity, relation = options.delete(:inverse).split('.')
        relationship[:destinationEntity] = relationship[:inverseEntity] = entity
        relationship[:inverseName] = relation
      else
        relationship[:destinationEntity] = relationship[:inverseEntity] = name.to_s.classify
        if options[:maxCount].to_s == "1"
          relationship[:inverseName] = self.name.underscore.pluralize
        else
          relationship[:inverseName] = self.name.underscore
        end
      end

      normalize_values(options, relationship)

      raw_relationship(relationship)
    end


    def has_one(name, options = {})
      relationship(name, {maxCount: 1, minCount: 1}.merge(options))
    end

    def has_many(name, options = {})
      relationship(name, {maxCount: -1, minCount: 1}.merge(options))
    end


    def self.convert_type(type)
      TYPE_MAPPING[type]
    end

    def to_xml(builder = nil)
      builder ||= Builder::XmlMarkup.new(:indent => 2)
      builder.entity(name: name, syncable: 'YES') do |xml|
        properties.each do |property|
          xml.attribute(property)
        end

        relationships.each do |relationship|
          xml.relationship(relationship)
        end
      end
    end

    private

    def normalize_values(source, destination)
      source.each do |key, value|
        destination[key] = normalize_value(value)
      end
    end

    def normalize_value(value)
      case value
      when false; 'NO'
      when true; 'YES'
      else value.to_s
      end
    end

  end
end
