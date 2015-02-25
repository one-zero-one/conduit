describe "#{Tillless::Conduit}: #{Tillless::Conduit::VERSION}" do

  it "should exist" do
    should.not.raise(NameError) { Tillless::Conduit::VERSION }
  end

  it 'should have a version string' do
    Tillless::Conduit::VERSION.should != nil
  end

end
