module Tillless
  module Conduit
    class PagedRestCommand < RestCommand
      attr_accessor :on_last_page, :load_all_pages, :per_page

      def self.new(args={})
        super(args).tap do |slf|
          slf.on_success   = args[:on_success]   || ->(paginator, objects, page) { slf.handle_success(paginator, objects, page) }
          slf.on_failure   = args[:on_failure]   || ->(paginator, error)         { slf.handle_failure(paginator, error)         }
          slf.on_last_page = args[:on_last_page] || ->(paginator)                { slf.handle_last_page(paginator)              }
        end
      end

      # Override to provide the verb, route and paramaters for the command, invokved during #run.
      def command
        NSLog "#{PagedRestCommand}##{__method__}: warning - override in derived PagedRestCommand class"
        [:get, nil, :unknown, {}]
      end

      # Asynchronously run the command and call :on_success, :on_failure or :on_last_page
      # depending on the outcome.
      def run(args={})
        @on_success     =   args[:on_success]     if args.has_key?(:on_success)
        @on_failure     =   args[:on_failure]     if args.has_key?(:on_failure)
        @on_last_page   =   args[:on_last_page]   if args.has_key?(:on_last_page)
        @load_all_pages =   args[:load_all_pages] if args.has_key?(:load_all_pages)
        @per_page       =   args[:per_page]       if args.has_key?(:per_page)
        @per_page       ||= 5

        @verb, @entity, @route, @params = self.command

        # # make sure paginator is configured
        # paginator

        # TODO: Fix this; see RestCommand#clear_cache_for_request_path
        clear_cache_for_request_path(@route)

        Dispatch::Queue.concurrent(:default).async do
          notify_command_started
          paginator.loadPage(1)
        end
        self
      end

      def paginator
        @paginator ||= begin
          Restikle::ResourceManager.manager.paginatorWithPathPattern(
            Restikle::ResourceManager.pagination_request(@route, @params)
          ).tap do |pager|
            pager.perPage = @per_page
            pager.setCompletionBlockWithSuccess(
              -> (paginator, objects, page) {
                cdq.save
                @on_success.call(paginator, objects, page)
                if @load_all_pages && paginator
                  if paginator.hasNextPage
                    notify_command_paged
                    paginator.loadNextPage
                  else
                    notify_command_stopped
                    @on_last_page.call(paginator)
                  end
                else
                  notify_command_paged
                  @on_last_page.call(paginator)
                end
              },
              failure: -> (paginator, error) {
                notify_command_errored
                @on_failure.call(paginator, error)
              }
            )
          end
        end
      end

      def handle_success(paginator, objects, page)
        NSLog "#{PagedRestCommand}##{__method__}: warning - override in derived command class, or provide via args[:on_success]"
        false
      end

      def handle_failure(paginator, error)
        NSLog "#{PagedRestCommand}##{__method__}: warning - override in derived command class, or provide via args[:on_failure]"
        false
      end

      def handle_last_page(paginator)
        NSLog "#{PagedRestCommand}##{__method__}: warning - override in derived command class, or provide via args[:on_last_page]"
        false
      end

    end
  end
end
