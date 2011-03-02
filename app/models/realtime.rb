require 'nokogiri'
require 'net/http'
require 'net/https'


class Realtime < ActiveRecord::Base

  attr_accessible :auto_login, :auto_password, :account_id, :password, :xml_content

  def self.new_valuation
    url = URI.parse(Settings.url)


    post_args = {
      'autologin' => Settings.auto_login,
      'autopassword' => Settings.auto_password,
      'accountid' => Settings.account_id,
      'password' => Settings.password,
      'content' => Settings.xml_content,
      'fuseaction' => 'api.interface'
    }

    resp, data = Net::HTTP.post_form(url, post_args)
    return data
  end

  def self.fetch(realtime_id)

    uri = URI.parse(Settings.url)

    post_args = {
      'autologin' => Settings.auto_login,
      'autopassword' => Settings.auto_password,
      'accountid' => Settings.account_id,
      'password' => Settings.password,
      'content' => Settings.xml_content,
      'fuseaction' => 'api.retrievevaluation',
      'realtimeValId' => realtime_id
    }

    logger.debug post_args

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #http.set_debug_output($stdout)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(post_args)
    response, data = http.request(request)
  end

  def self.has_errors(xml)
    @xml_doc = Nokogiri::XML(xml)
    @errors = @xml_doc.xpath('//errors/error')

    @outcome = false
    @message = 'no errors'

    if @errors.size > 0
      @outcome = true
      @message = @errors.first['errormessage']
    end

    return @outcome, @message
  end

  def self.parse_xml(xml)
    @xml_doc = Nokogiri::XML(xml)
    
    @property_details = @xml_doc.xpath('//valuationproperty')
    @valuation_details = @xml_doc.xpath('//valuationresult')

    {:address => @property_details.first['concataddress'] + ' in ' + @property_details.first['suburb'], :cl => @valuation_details.first['confidencelevel'], :valuation => @valuation_details.first['realtimevaluation']}
  end
end
