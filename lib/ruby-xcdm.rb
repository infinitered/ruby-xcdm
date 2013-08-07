require 'xcdm/schema'
require 'xcdm/entity'

if defined?(Motion::Project::Config)

  namespace :schema do

    desc "Clear the datamodel outputs"
    task :clean do
      files = Dir.glob(File.join(App.config.project_dir, 'resources', App.config.name) + ".{momd,xcdatamodeld}")
      files.each do |f|
        rm_rf f
      end
    end

    desc "Generate the xcdatamodel file"
    task :build => :clean do
      Dir.chdir App.config.project_dir
      if `xcodebuild -version` =~ /Xcode (\d.\d+)/
        xcode_version = $1
        p "Xcode version: '#{xcode_version}'"
      else
        raise "could not determine xcode version"
      end
      runner = XCDM::Schema::Runner.new( App.config.name, "schemas", "resources", App.config.sdk_version)
      App.info "Generating", "Data Model #{App.config.name}"
      runner.load_all { |schema, file| App.info "Loading", file }
      runner.write_all { |schema, file| App.info "Writing", file }
    end
  end

  task :"build:simulator" => :"schema:build"
  task :"build:device" => :"schema:build"

end
