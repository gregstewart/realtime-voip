class MessagingController < ApplicationController
  def index
    if !params['session'].nil?
      #initial_text captures the very first sms or IM sent to tropo
      initial_text = params["session"]["initialText"]
      from = params["session"]["from"]
      network = from["network"]
      from_id = from["id"] # this field contains IM login or phone number in case of incoming SMS
      if network == "SMS" || network == "JABBER"
        render :json => parse(initial_text)
      else if network == "VOICE"
        render :json => Tropo::Generator.say("Hello")
      else
        render :json => Tropo::Generator.say("Unsupported operation")
      end
    else
      render :json => {:error => "There was an error"}
    end
  end

  private

  def parse(input)
    input.strip!
    # do whatever parsing you need.  in this example, if user types "n what a new day", tropo will
    # respond him with "you said: what a new day"
    if m = input.match(/^(n|N)\s+/)
      Tropo::Generator.say "you said: " + m.post_match
    else
      Tropo::Generator.say "Unsupported operation."
    end
  end
end