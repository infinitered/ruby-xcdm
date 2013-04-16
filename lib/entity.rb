
class Entity

  DEFAULT_ATTRIBUTES = { :optional => 'YES', :syncable => 'YES' }
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


  attr_reader :name, :properties

  def initialize(name, options = {})
    @name = name
    @properties = []
  end

  def raw_property(options)
    @properties << DEFAULT_ATTRIBUTES.merge(options)
  end
  
  def property(name, type, options = {})
    property = {}
    property[:propertyType] = self.class.convert_type(type)
    property[:name] = name
    options.each do |key, value|
      value = case value
              when false; 'NO'
              when true; 'YES'
              else value
              end
      property[key] = value
    end
    @properties << DEFAULT_ATTRIBUTES.merge(property)
  end

  def self.convert_type(type)
    TYPE_MAPPING[type]
  end

  # Make shortcut property methods for each data type
  TYPE_MAPPING.keys.each do |type|
    define_method(type) do |name, options = {}|
      property(name, type, options)
    end
  end

end
