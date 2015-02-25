describe Tillless::Conduit::TC::GetStateCommand do
  extend WebStub::SpecHelpers

  it "should exist" do
    should.not.raise(NameError) { Tillless::Conduit::TC::GetStateCommand }
  end

  URL_FOR_GET_STATES_1  = 'http://api.tillless.com/api/states/1'
  JSON_FOR_GET_STATES_1 = BW::JSON.parse <<EOF
{
  "id": 1,
  "name": "Canillo",
  "abbr": "02",
  "country_id": 1
}
EOF

  # Run once at the beginning to set up CDQ and Restikle before all tests
  describe "#{Tillless::Conduit::TC::GetStateCommand} CDQ and ResourceManager setup" do
    it "should setup #{Restikle::ResourceManager}" do
      Tillless::Conduit::Spec.setup_cdq_and_resource_manager.should == true
    end
  end

  # Command specs (separated from CDQ setup / reset)
  describe "#{Tillless::Conduit::TC::GetStateCommand} specs" do

    before do
      setup_rest_web_stubs
    end

    after do
      teardown_rest_web_stubs
    end

    def setup_rest_web_stubs
      stub_request(
        :get, URL_FOR_GET_STATES_1).
        to_return(json: JSON_FOR_GET_STATES_1)
    end

    def teardown_rest_web_stubs
      reset_stubs
    end

    it "#{Tillless::Conduit::TC::GetStateCommand}.run" do
      @status = :unknown
      @cmd    = Tillless::Conduit::TC::GetStateCommand.new(id: 1).run(
        on_success: ->(op,res) {
          # puts  "\n  - op: #{op.inspect}"
          # print  "  - res: #{res.inspect}"
          cdq.save
          @status = :success
          resume
        },
        on_failure: ->(op,err) {
          # puts  "\n  - op: #{op.inspect}"
          # print  "  - err: #{err.inspect}"
          @status = :failed
          resume
        }
      )

      wait_max 20.0 do
        @status.should != :failed
        @status.should != :unknown
        @status.should == :success

        @country = Country.where(:id).eq(1).first
        @country.should != nil
        @country.id.should == 1
        # puts "@country: #{@country.inspect}"
      end
    end

  end
end
