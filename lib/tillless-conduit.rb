# encoding: utf-8
unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

lib_dir_path    = File.dirname(File.expand_path(__FILE__))
motion_dir_path = File.join(lib_dir_path, '../motion')
Motion::Project::App.setup do |app|
  app.resources_dirs << File.join(File.dirname(__FILE__), '../resources')
  app.files.concat(Dir.glob(File.join(motion_dir_path, "tillless-conduit/**/*.rb")))
  app.files.concat(Dir.glob(File.join(lib_dir_path,    "tillless-conduit/**/*.rb")))
end
