require 'spec_helper'

describe Realtime do
  
  before(:each) do
    @url = "http://greg-stewarts-computer.realtimevaluation.com.au/"
    @xml_response = '<?xml version="1.0" ?><hometrack><realtime interfaceversion="2.1" accountid="12352"><valuationresponse orderid="114743"><errors/><valuationresult realtimevalid="8073737" realtimevalauth="NypcJC1SX1wyXzgrMlYmVzZYXVxFUSBLODg9UDZfXEwgCg==" datetime="Feb 23 2011  9:59AM" realtimevaluation="703000" confidencelevel="6.25000000" fsd="0.09000000" valuerangelower="640000" valuerangeupper="767000"><errors/><warnings/><valuationproperty postcode="2204" buildingnumber="87" street="PREMIER ST" suburb="MARRICKVILLE" concataddress="87 PREMIER ST" propertytypeid="3" propertytype="House" htproptypeid="3" addresspointtoid="1350482" asofdate="Feb 22 2011 12:00AM" knownvalue="125000" knownvaluedate="Mar 30 1988 12:00AM" yearbuilt="1930" reference="api_test" x_coord="1239356.040" y_coord="1469259.480" lat="-33.920726080000001" lon="151.153207049999990"/><addressmatching apiused="false" matched="false" foundindatabase="true" inputaddress="87 PREMIER ST MARRICKVILLE 2204"/></valuationresult></valuationresponse></realtime></hometrack>'

    @auto_login = ''
    @auto_password = ''
    @account_id = 0
    @password = ''
    @xml_request = '<hometrack><realtime accountid="12352"><valuationrequest><property reference="api_test" propertytype="3" streetnum="87" street="PREMIER" streettype="ST" suburb="MARRICKVILLE" postcode="2204" state="NSW"/></valuationrequest></realtime></hometrack>'

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

  it "should make a new call to realtime" do
    WebMock.allow_net_connect!

    response = Realtime.new_valuation()
    response.should == @xml_response

  end

  it "should retrieve an existing valuation" do
    WebMock.allow_net_connect!

    response = Realtime.fetch(0)
    response.should == @xml_response
  end

end
