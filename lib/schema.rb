
require 'entity'

class Schema

  attr_reader :version, :entities

  def initialize(version)
    @version = version
    @entities = []
  end

  def entity(name, &block)
    @entities << Entity.new(name).tap { |e| e.instance_eval(&block) }
  end

end
