
require 'xcdm/entity'
require 'fileutils'
require 'plist'

module XCDM

  class Schema

    attr_reader :version, :entities, :xcode_version

    def initialize(version, xcode_version)
      @version = version
      @xcode_version = xcode_version
      @entities = []
    end

    def entity(name, options = {}, &block)
      @entities << Entity.new(self, name, options).tap { |e| e.instance_eval(&block) }
    end

    def to_xml(builder = nil)

      builder ||= Builder::XmlMarkup.new(:indent => 2)

      builder.instruct! :xml, :standalone => 'yes'

      if xcode_version =~ /5\.x/
        attrs = {
          name: "",
          userDefinedModelVersionIdentifier: version,
          type: "com.apple.IDECoreDataModeler.DataModel",
          documentVersion: "1.0",
          lastSavedToolsVersion: "3389",
          systemVersion: "12E55",
          minimumToolsVersion: "Xcode 5",
          macOSVersion: "Automatic",
          iOSVersion: "Automatic"
        }
      else
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
      end

      builder.model(attrs) do |builder|
        entities.each do |entity|
          entity.to_xml(builder)
        end
      end
    end

    class Loader

      attr_reader :schemas
      attr_reader :xcode_version

      def initialize(xcode_version)
        @xcode_version = xcode_version
        @schemas = []
      end

      def schema(version, options = {}, &block)
        xcv = options[:xcode_version] || xcode_version
        @found_schema = Schema.new(version, xcv).tap { |s| s.instance_eval(&block) }
        @schemas << @found_schema
      end

      def load_file(file)
        File.open(file) do |ff|
          instance_eval(ff.read, file)
        end
        @found_schema
      end

    end

    class Runner
      def initialize(name, inpath, outpath, xcode_version = nil)
        @inpath = inpath
        @name = name
        @container_path = File.join(outpath, "#{name}.xcdatamodeld")
        if !xcode_version
          begin
            `xcodebuild -version` =~ /(\d+\.\d+\.\d+)/
            xcode_version = $1
          rescue => e
            p e
            puts "XCode not installed?"
          end
        end
        @loader = Loader.new(xcode_version)
      end

      def datamodel_file(version)
        dir = File.join(@container_path, "#{version}.xcdatamodel")
        FileUtils.mkdir_p(dir)
        File.join(dir, 'contents')
      end

      def load_all(&block)
        Dir["#{@inpath}/*.rb"].each do |file|
          if File.file?(file)
            schema = @loader.load_file(file)
            block.call(schema, file) if block_given?
          end
        end
      end

      def write_all(&block)
        @loader.schemas.each do |schema|
          filename = datamodel_file(schema.version)
          block.call(schema, filename) if block_given?
          File.open(filename, "w+") do |f|
            f.write(schema.to_xml)
          end
        end

        max = @loader.schemas.map(&:version).max
        File.open(File.join(@container_path, ".xccurrentversion"), "w+") do |f|
          f.write({ "_XCCurrentVersionName" => "#{max}.xcdatamodel" }.to_plist)
        end

      end

    end
  end
end
