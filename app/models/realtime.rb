require 'net/http'

class Realtime < ActiveRecord::Base

  attr_accessible :auto_login, :auto_password, :account_id, :password, :xml_content

  def self.new_valuation
    url = URI.parse('http://greg-stewarts-computer.realtimevaluation.com.au/')


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

    url = URI.parse('http://greg-stewarts-computer.realtimevaluation.com.au/')


    post_args = {
      'autologin' => :auto_login,
      'autopassword' => :auto_password,
      'accountid' => :account_id,
      'password' => :password,
      'content' => :xml_content,
      'fuseaction' => 'api.retrievevaluation',
      'realtimeValId' => realtime_id
    }
    resp, data = Net::HTTP.post_form(url, post_args)
    return data
    
  end

end
