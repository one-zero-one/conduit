# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'motion/project/template/gem/gem_tasks'

require 'bundler'
require 'bundler/gem_tasks'

begin
  if ARGV.join(' ') =~ /spec/
    Bundler.require :default, :spec
  else
    Bundler.require
  end
rescue Exception => e
  puts "Exception processing Bundler.require:"
  puts e
end

require 'ib'
require 'cdq'
require 'rubygems'
require 'motion-cocoapods'
require 'bubble-wrap'
require 'bubble-wrap/all'
require 'sugarcube-all'
require 'motion-support/inflector'
require 'webstub'
require 'restikle'
require 'tillless-conduit'

Motion::Project::App.setup do |app|
  app.deployment_target    = '8.1'
  app.name                 = 'T-Conduit'
  app.identifier           = 'com.tillless.generic-dev.conduit'
  app.codesign_certificate = 'iPhone Developer: Matthew Sinclair (ET7NR2G8D7)'
  app.provisioning_profile = 'provisioning/Tillless_Generic_Development.mobileprovision'

  app.frameworks += [
    'CoreData',
    'MobileCoreServices',
    'Security',
    'UIKit',
    'SystemConfiguration'
  ]
  app.detect_dependencies    = true
  app.interface_orientations = [:portrait]

  if ARGV.include? 'spec'
    app.name = 'T-Conduit Spec'
  end

  app.pods do
    pod 'AFNetworking', '~> 1.3.4'
    pod 'RestKit'
    pod 'NSData+MD5Digest'
    pod 'NSData+Base64'
  end

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
task :"build:simulator" => :"schema:build"
