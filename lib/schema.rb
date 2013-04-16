
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

  class Loader

    def schema(version, &block)
      @found_schema = Schema.new(version).tap { |s| s.instance_eval(&block) }
    end

    def load_file(file)
      File.open(file) do |ff|
        instance_eval(ff.read, file)
      end
      @found_schema
    end

  end

end
