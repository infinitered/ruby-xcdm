
require 'entity'
require 'fileutils'

class Schema

  attr_reader :version, :entities

  def initialize(version)
    @version = version
    @entities = []
  end

  def entity(name, &block)
    @entities << Entity.new(name).tap { |e| e.instance_eval(&block) }
  end

  def to_xml(builder = nil)

    builder ||= Builder::XmlMarkup.new(:indent => 2)

    builder.instruct! :xml, :standalone => 'yes'

    attrs = {
      name: "",
      userDefinedModelVersionIdentifier: version,
      type: "com.apple.IDECoreDataModeler.DataModel",
      documentVersion: "1.0", 
      lastSavedToolsVersion: "2061",
      systemVersion: "12D78",
      minimumToolsVersion: "Xcode 4.3",
      macOSVersion: "Automatic",
      iOSVersion: "Automatic"
    }

    builder.model(attrs) do |builder|
      entities.each do |entity|
        entity.to_xml(builder)
      end
    end
  end

  class Loader

    attr_reader :schemas

    def initialize
      @schemas = []
    end

    def datamodel_file(version)
      File.join(@container_path, "#{version}.xcdatamodel", 'contents')
    end

    def schema(version, &block)
      @found_schema = Schema.new(version).tap { |s| s.instance_eval(&block) }
      @schemas << @found_schema 
    end

    def load_file(file)
      File.open(file) do |ff|
        instance_eval(ff.read, file)
      end
      @found_schema
    end

    class Runner
      def initialize(name, inpath, outpath)
        @inpath = inpath
        @name = name
        @container_path = File.join(outpath, "#{name}.xcdatamodeld")
        @loader = Loader.new
      end

      def load_all
        Dir.entries(inpath).each do |file|
          if File.file?(file)
            load_file(file)
          end
        end
      end

      def write_all
        schemas.each do |schema|
          File.open(datamodel_file(schema.version), "w") do |f|
            f.write(schema.to_xml)
          end
        end
      end

    end
  end

end
