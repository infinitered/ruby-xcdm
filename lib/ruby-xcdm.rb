require 'xcdm/schema'
require 'xcdm/entity'

if defined?(Motion::Project::Config)

  class Motion::Project::Config
    variable :xcdm

    def xcdm
      @xcdm ||= Struct.new(:name).new(nil)
    end
  end

  if File.directory?(File.join(App.config.project_dir, "schemas"))
    namespace :schema do

      desc "Clear the datamodel outputs"
      task :clean do
        App.config.xcdm.name ||= App.config.name
        files = Dir.glob(File.join(App.config.project_dir, 'resources', App.config.xcdm.name) + ".{momd,xcdatamodeld}")
        files.each do |f|
          rm_rf f
        end
      end

      desc "Generate the xcdatamodel file"
      task :build => :clean do
        App.config.xcdm.name ||= App.config.name
        Dir.chdir App.config.project_dir
        if `xcodebuild -version` =~ /Xcode (\d+.\d+)/
          xcode_version = $1
        else
          raise "could not determine xcode version"
        end
        runner = XCDM::Schema::Runner.new( App.config.xcdm.name, "schemas", "resources", App.config.sdk_version)
        App.info "Generating", "Data Model #{App.config.xcdm.name}"
        runner.load_all { |schema, file| App.info "Loading", file }
        runner.write_all { |schema, file| App.info "Writing", file }
      end
    end
  end

end
