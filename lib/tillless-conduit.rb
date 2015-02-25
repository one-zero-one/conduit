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

  # TODO: Manually enforce dependencies between common and adapter classes
  custom_dependencies = [
    [ '/rest_command.rb',            ['get_country_command.rb', 'get_state_command.rb']],
    [ '/paged_rest_command.rb',      ['get_products_command.rb' ]]
  ]
  custom_dependencies.each do |dep|
    to   = app.files.flatten.select {|f| f.match(dep[0]) }.first
    from = []
    dep[1].each do |fd|
      to_dep = app.files.flatten.select {|f| f.match(fd) }.first
      from << to_dep unless to_dep.nil?
    end
    from.each do |fr|
      app.files_dependencies(fr => to)
    end
  end
end
