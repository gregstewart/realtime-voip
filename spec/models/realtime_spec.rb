require 'spec_helper'

describe Realtime do
  
  before(:each) do
    

    @url = Settings.url
    @xml_response = Settings.xml_response

    @auto_login = Settings.auto_login
    @auto_password = Settings.auto_password
    @account_id = Settings.account_id
    @password = Settings.password
    @xml_request = Settings.xml_request

    @attr = { :auto_login => @auto_login,
              :auto_password => @auto_password,
              :account_id => @account_id,
              :password => @password,
              :xml_content => @xml_request}
  end

  it "should create a realtime object given valid attributes" do
    Realtime.create!(@attr)
  end

  it "should make a mock successful call to Realtime" do
    #WebMock.stub_request(:post, @url).with(:body => {:data => { 'fuseaction' => 'api.interface', 'autologin' => @auto_login,  'autopassword' => @auto_password, 'accountId' => @account_id, 'password' => @password, 'content'=> @xml_request}}, :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'})
    WebMock.stub_request(:post, @url).
  with(:body => 'fuseaction=api.interface&autologin=apitest&autopassword=h0m3tr4ck673&accountid=12352&password=h0m3tr4ck672&content=%3chometrack%3e%3crealtime%20accountid%3d%2212352%22%3e%3cvaluationrequest%3e%3cproperty%20reference%3d%22api_test%22%20propertytype%3d%223%22%20streetnum%3d%2287%22%20street%3d%22PREMIER%22%20streettype%3d%22ST%22%20suburb%3d%22MARRICKVILLE%22%20postcode%3d%222204%22%20state%3d%22NSW%22%2f%3e%3c%2fvaluationrequest%3e%3c%2frealtime%3e%3c%2fhometrack%3e',
       :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "", :headers => {})

    #Actual request
    url = URI.parse(@url)

    post_args = {
      'fuseaction' => 'api.interface', 
      'autologin' => @auto_login,
      'autopassword' => @auto_password,
      'accountid' => @account_id,
      'password' => @password,
      'content' => @xml_request
    }

    resp, data = Net::HTTP.post_form(url, post_args)

    WebMock.should have_requested(:post, @url).with(:body => 'fuseaction=api.interface&autologin=apitest&autopassword=h0m3tr4ck673&accountid=12352&password=h0m3tr4ck672&content=%3chometrack%3e%3crealtime%20accountid%3d%2212352%22%3e%3cvaluationrequest%3e%3cproperty%20reference%3d%22api_test%22%20propertytype%3d%223%22%20streetnum%3d%2287%22%20street%3d%22PREMIER%22%20streettype%3d%22ST%22%20suburb%3d%22MARRICKVILLE%22%20postcode%3d%222204%22%20state%3d%22NSW%22%2f%3e%3c%2fvaluationrequest%3e%3c%2frealtime%3e%3c%2fhometrack%3e').once

  end

  #it "should make a new call to realtime" do
  #  WebMock.allow_net_connect!
  #
  #  response = Realtime.new_valuation()
  #  response.should == @xml_response
  #
  #end

  it "should connect to the au realtime instance" do
    WebMock.allow_net_connect!

    @response = Realtime.fetch(8073738)
    @response.code == 200.to_s
  end

  it "should fail error check" do
    xml = '<?xml version="1.0" ?>
				<hometrack>
					<realtime accountid="-1">
						<valuationresponse>
							<errors>
								<error errorid="3" errormessage="Incorrect Login details supplied"/>
							</errors>
		   				</valuationresponse>
					</realtime>
				</hometrack>'
    result = Realtime.has_errors xml
    result.should be_true
  end

  it "should pass error check" do
    result = Realtime.has_errors @xml_response
    result.should == [false, 'no errors']
  end

  it "should return successfully parse valuation" do
    result = Realtime.parse_xml @xml_response

    result.should == {:address => "87 PREMIER ST", :cl => "6.25000000", :valuation => "703000"}
  end

  it "should retrieve an existing valuation through the AU instance" do
    WebMock.allow_net_connect!
    #8131384
    # live - 8633100
    response = RealtimeAu.get_valuation(8634853)
    response.should == {:address => "87 PREMIER ST in MARRICKVILLE", :cl => "6.25000000", :valuation => "699000"}
  end
end
