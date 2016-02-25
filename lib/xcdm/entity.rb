
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
      binary:        'Binary',
      transformable: 'Transformable'
    }


    attr_reader :name, :properties, :relationships, :class_name, :parent, :abstract, :user_info


    def initialize(schema, name, options = {})
      @options = options.dup
      @schema = schema
      @name = name
      @class_name = @options.delete(:class_name) || name
      @properties = []
      @user_info = []
      @relationships = []
      @parent = @options.delete(:parent)
      if @parent
        @options['parentEntity'] = parent
      end
      @abstract = @options.delete(:abstract)
      if @abstract
        @options['isAbstract'] = normalize_value(@abstract)
      end
    end

    def user_info(entries = {})
      @user_info << normalize_user_info_entries(entries)
      @user_info.flatten!
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
      elsif options.key?(:default)
        options.delete(:default)
      elsif [:integer16, :integer32, :integer64].include?(type)
        property[:defaultValueString] = "0"
      elsif [:float, :double, :decimal].include?(type)
        property[:defaultValueString] = "0.0"
      end

      if options[:user_info].present?
        property[:user_info] = normalize_user_info_entries(options.delete(:user_info))
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
        options.delete(:plural_inverse)
      else
        relationship[:destinationEntity] = relationship[:inverseEntity] = name.to_s.classify
        if options.delete(:plural_inverse)
          relationship[:inverseName] = self.name.underscore.pluralize
        else
          relationship[:inverseName] = self.name.underscore
        end
      end

      if options[:user_info]
        relationship[:user_info] = normalize_user_info_entries(options.delete(:user_info))
      end

      normalize_values(options, relationship)
      raw_relationship(relationship)
    end

    def belongs_to(name, options = {})
      case @schema.xcode_version
      when /4\..*/
        options = {maxCount: 1, minCount: 1, plural_inverse: true}.merge(options)
      else
        options = {maxCount: 1, plural_inverse: true}.merge(options)
      end
      relationship(name, options)
    end

    def has_one(name, options = {})
      case @schema.xcode_version
      when /4\..*/
        options = {maxCount: 1, minCount: 1}.merge(options)
      else
        options = {maxCount: 1}.merge(options)
      end
      relationship(name, options)
    end

    def has_many(name, options = {})
      case @schema.xcode_version
      when /4\..*/
        options = {maxCount: -1, minCount: 1}.merge(options)
      else
        options = {toMany: true}.merge(options)
      end
      relationship(name, options)
    end


    def self.convert_type(type)
      TYPE_MAPPING[type]
    end

    def to_xml(builder = nil)
      builder ||= Builder::XmlMarkup.new(:indent => 2)
      options = { name: name, syncable: 'YES', representedClassName: class_name }.merge(@options)
      builder.entity(options) do |xml|
        properties.each do |property|
          entries = property.delete(:user_info)

          xml.attribute(property) do |attribute|
            if entries
              add_user_info_entries(attribute, entries)
            end
          end
        end

        relationships.each do |relationship|
          entries = relationship.delete(:user_info)

          xml.relationship(relationship) do |relationship_xml|
            if entries
              add_user_info_entries(relationship_xml, entries)
            end
          end
        end

        add_user_info_entries(xml, user_info) unless user_info.empty?
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

    def normalize_user_info_entries(user_info)
      user_info.map do |key, value|
        { key: key, value: value }
      end
    end

    def add_user_info_entries(xml, entries)
      xml.userInfo do |user_info|
        entries.each do |entry|
          user_info.entry(entry)
        end
      end
    end
  end
end
