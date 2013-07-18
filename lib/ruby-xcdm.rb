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
      runner = XCDM::Schema::Runner.new( App.config.name, "schemas", "resources")
      runner.load_all
      runner.write_all
    end
  end

  task :"build:simulator" => :"schema:build"
  task :"build:device" => :"schema:build"


else

  require 'xcdm/schema'
  require 'xcdm/entity'

end
