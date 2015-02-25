module Tillless
  module Conduit
    class RestCommand
      include CDQ
      include Notifications
      attr_accessor :clear_cache
      attr_accessor :on_success, :on_failure
      attr_accessor :verb, :entity, :route, :params

      def self.new(args={})
        super(args).tap do |slf|
          slf.on_success  = args[:on_success]  || ->(op,res) { slf.handle_success(op,res) }
          slf.on_failure  = args[:on_failure]  || ->(op,err) { slf.handle_failure(op,err) }
          slf.clear_cache = args[:clear_cache] || true
        end
      end


      # Override to provide the verb, route and paramaters for the command, invokved during #run.
      def command
        NSLog "#{RestCommand}##{__method__}: warning - override in derived RestCommand class"
        [:unknown, nil, :unknown, {}]
      end

      # Asynchronously run the command and call :on_success or :on_failure depending on the outcome.
      def run(args={})
        @on_success = args[:on_success] if args.has_key?(:on_success)
        @on_failure = args[:on_failure] if args.has_key?(:on_failure)
        @verb, @entity, @route, @params = self.command
        dispatch(@verb, @entity, @route, @params)
      end

      RK_MANAGER_METHODS = {
        get:    'getObject:path:parameters:success:failure',
        post:   'postObject:path:parameters:success:failure',
        patch:  'patchObject:path:parameters:success:failure',
        put:    'putObject:path:parameters:success:failure',
        delete: 'deleteObject:path:parameters:success:failure'
      }
      def dispatch(verb, entity, route, params)
        Dispatch::Queue.concurrent(:default).async do
          clear_cache_for_request_path(route) if @clear_cache
          notify_command_started
          case verb
          when :get
            self.get_object(entity, route, params)
          when :post
            self.post_object(entity, route, params)
          when :put
            self.put_object(entity, route, params)
          when :delete
            self.delete_object(entity, route, params)
          when :patch
            self.patch_object(entity, route, params)
          else
            NSLog "#{RestCommand}##{__method__}: error - unknown verb: #{verb}"
          end
        end
      end

      def get_object(entity, route, params)
        Restikle::ResourceManager.manager.getObject(
          entity,
          path: route,
          parameters: params,
          success: ->(op,res) {
            notify_command_stopped
            @on_success.call(op, res) if @on_success
          },
          failure: ->(op,err) {
            notify_command_errored
            @on_failure.call(op, err) if @on_failure
          }
        )
      end
      def post_object(entity, route, params)
        Restikle::ResourceManager.manager.postObject(
          entity,
          path: route,
          paramaters: params,
          success: ->(op,res) {
            notify_command_stopped
            @on_success.call(op, res) if @on_success
          },
          failure: ->(op,err) {
            notify_command_errored
            @on_failure.call(op, err) if @on_failure
          }
        )
      end
      def put_object(entity, route, params)
        Restikle::ResourceManager.manager.putObject(
          entity,
          path: route,
          paramaters: params,
          success: ->(op,res) {
            notify_command_stopped
            @on_success.call(op, res) if @on_success
          },
          failure: ->(op,err) {
            notify_command_errored
            @on_failure.call(op, err) if @on_failure
          }
        )
      end
      def delete_object(entity, route, params)
        Restikle::ResourceManager.manager.deleteObject(
          entity,
          path: route,
          paramaters: params,
          success: ->(op,res) {
            notify_command_stopped
            @on_success.call(op, res) if @on_success
          },
          failure: ->(op,err) {
            notify_command_errored
            @on_failure.call(op, err) if @on_failure
          }
        )
      end
      def patch_object(entity, route, params)
        Restikle::ResourceManager.manager.patchObject(
          entity,
          path: route,
          paramaters: params,
          success: ->(op,res) {
            notify_command_stopped
            @on_success.call(op, res) if @on_success
          },
          failure: ->(op,err) {
            notify_command_errored
            @on_failure.call(op, err) if @on_failure
          }
        )
      end

      def rk_request_method_for(verb)
        Restikle::ResourceManager.instrumentor.rk_request_method_for(verb)
      end


      # Cache

      def clear_cache_for_request_path(path)
        if self.clear_cache
          # TODO: Fix this! Looks like a bug with NSURLCache, see: http://stackoverflow.com/questions/25596424/nsurlcaches-removecachedresponseforrequest-has-no-effect
          # req = NSURLRequest.alloc.initWithURL("#{Restikle::ResourceManager.manager.baseURL.to_s}#{path}".nsurl)
          # NSURLCache.sharedURLCache.removeCachedResponseForRequest(req)
          NSURLCache.sharedURLCache.removeAllCachedResponses
        end
      end


      # Handlers

      def handle_success(operation, result)
        NSLog "#{RestCommand}##{__method__}: warning - override in derived command class, or provide via args[:on_success]"
        false
      end

      def handle_failure(operation, error)
        NSLog "#{RestCommand}##{__method__}: warning - override in derived command class, or provide via args[:on_failure]"
        false
      end


      # Notifications

      def notify_command_started
        NSLog "#{RestCommand}##{__method__}"
        Tillless::Conduit::Notifications::COMMAND_STARTED.post_notification(nil, {command: self})
      end
      def notify_command_paged
        NSLog "#{RestCommand}##{__method__}"
        Tillless::Conduit::Notifications::COMMAND_PAGED.post_notification(nil,   {command: self})
      end
      def notify_command_stopped
        NSLog "#{RestCommand}##{__method__}"
        Tillless::Conduit::Notifications::COMMAND_STOPPED.post_notification(nil, {command: self})
      end
      def notify_command_errored
        NSLog "#{RestCommand}##{__method__}"
        Tillless::Conduit::Notifications::COMMAND_ERRORED.post_notification(nil, {command: self})
      end
    end
  end
end
