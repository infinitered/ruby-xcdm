
class Entity

  DEFAULT_ATTRIBUTES = { :optional => 'YES', :syncable => 'YES' }

  attr_reader :name, :attributes

  def initialize(name, options = {})
    @name = name
    @attributes = []
  end

  def raw_attribute(options)
    @attributes << DEFAULT_ATTRIBUTES.merge(options)
  end

end
