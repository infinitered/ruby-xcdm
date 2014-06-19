require 'xcdm/schema'
require 'xcdm/entity'

if defined?(Motion::Project::Config)

  if File.directory?(File.join(App.config.project_dir, "schemas"))
    namespace :schema do

      desc "Clear the datamodel outputs"
      task :clean do
        files = Dir.glob(File.join(App.config.project_dir, 'resources', App.config.info_plist['CDQDBName'] || App.config.name) + ".{momd,xcdatamodeld}")
        files.each do |f|
          rm_rf f
        end
      end

      desc "Generate the xcdatamodel file"
      task :build => :clean do
        Dir.chdir App.config.project_dir
        if `xcodebuild -version` =~ /Xcode (\d.\d+)/
          xcode_version = $1
        else
          raise "could not determine xcode version"
        end
        name = App.config.info_plist['CDQDBName'] || App.config.name
        runner = XCDM::Schema::Runner.new( name, "schemas", "resources", App.config.sdk_version)
        App.info "Generating", "Data Model #{name}"
        runner.load_all { |schema, file| App.info "Loading", file }
        runner.write_all { |schema, file| App.info "Writing", file }
      end
    end
  end

end
