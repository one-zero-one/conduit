module Tillless
  module Conduit
    module TC
      class GetStateCommand < Tillless::Conduit::RestCommand
        attr_accessor :id, :state

        def self.new(args={})
          super(args).tap do |slf|
            slf.id      = args[:id]
            slf.state = args[:state]
          end
        end

        def command
          @state ||= State.where(:id).eq(@id).first
          [:get, @state, "states/#{@id}", nil]
        end
      end
    end
  end
end
