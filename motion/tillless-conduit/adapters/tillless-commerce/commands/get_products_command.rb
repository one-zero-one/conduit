module Tillless
  module Conduit
    module TC
      class GetProductsCommand < Tillless::Conduit::PagedRestCommand
        def command
          [:get, nil, 'products', nil]
        end
      end
    end
  end
end
