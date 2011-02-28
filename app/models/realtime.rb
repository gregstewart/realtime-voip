require 'nokogiri'
require 'net/http'
require 'net/https'


class Realtime < ActiveRecord::Base

  attr_accessible :auto_login, :auto_password, :account_id, :password, :xml_content

  def self.new_valuation
    url = URI.parse(Settings.url)


    post_args = {
      'autologin' => :auto_login,
      'autopassword' => :auto_password,
      'accountid' => :account_id,
      'password' => :password,
      'content' => :xml_content,
      'fuseaction' => 'api.interface'
    }

    resp, data = Net::HTTP.post_form(url, post_args)
    return data
  end

  def self.fetch(realtime_id)

    uri = URI.parse(Settings.url)

    post_args = {
      'autologin' => :auto_login,
      'autopassword' => :auto_password,
      'accountid' => :account_id,
      'password' => :password,
      'content' => :xml_content,
      'fuseaction' => 'api.retrievevaluation',
      'realtimeValId' => realtime_id
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #http.set_debug_output($stdout)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(post_args)
    response, data = http.request(request)
  end

  def self.has_errors(xml)
    xml = Nokogiri::XML(xml)
    errors = xml.xpath('//errors/error')
    outcome = false
    message = 'no errors'

    if errors.size > 0
      outcome = true
      message = errors.first['errormessage']
    end

    return outcome, message 
  end

  def self.parse_xml(xml)
    xml_doc = Nokogiri::XML(xml)
    property_details = xml_doc.xpath('//valuationproperty')
    valuation_details = xml_doc.xpath('//valuationresult')

    {:address => property_details.first['concataddress'], :cl => valuation_details.first['confidencelevel'], :valuation => valuation_details.first['realtimevaluation']}
  end
end
