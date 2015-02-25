module Tillless
  module Conduit
    module Spec
      URL_FOR_SPECS = 'http://api.tillless.com/api/'

      def self.setup_cdq_and_resource_manager
        @@specs_cdq_is_setup              ||= false
        @@specs_resource_manager_is_setup ||= false

        unless @@specs_cdq_is_setup
          CDQ.cdq.setup
          @@specs_cdq_is_setup = true
        end

        unless @@specs_resource_manager_is_setup
          print ' '
          print "Restikle setup:\n"
          print "  using API endpoint: "
          Restikle::ResourceManager.set_api_host URL_FOR_SPECS
          Restikle::ResourceManager.setup
          print "#{Restikle::ResourceManager.api_host}\n"
          print "      loading schema: "
          Restikle::ResourceManager.load_schema(file: 'tillless-commerce.schema', remove_from_entities: 'spree_')
          print "#{Restikle::ResourceManager.entities.size} entities processed\n"
          print "      loading routes: "
          Restikle::ResourceManager.load_routes(file: 'tillless-commerce.routes', remove_from_paths: '/api/')
          print "#{Restikle::ResourceManager.routes.size} routes processed\n"
          print "   building mappings: "
          Restikle::ResourceManager.build_mappings
          print "#{Restikle::ResourceManager.mappings_created} mappings created\n"
          @@specs_resource_manager_is_setup = true
        end

        @@specs_cdq_is_setup && @@specs_resource_manager_is_setup
      end

      def self.teardown_cdq_and_resource_manager
        @@specs_cdq_is_setup              = nil
        @@specs_resource_manager_is_setup = nil
        CDQ.cdq.reset!
        Restikle::ResourceManager.reset!
      end
    end
  end
end
