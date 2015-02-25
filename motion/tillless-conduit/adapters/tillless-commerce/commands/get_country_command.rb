module Tillless
  module Conduit
    module TC
      class GetCountryCommand < Tillless::Conduit::RestCommand
        attr_accessor :id, :country

        def self.new(args={})
          super(args).tap do |slf|
            slf.id      = args[:id]
            slf.country = args[:country]
          end
        end

        def command
          @country ||= Country.where(:id).eq(@id).first
          [:get, @country, "countries/#{@id}", nil]
        end
      end
    end
  end
end
