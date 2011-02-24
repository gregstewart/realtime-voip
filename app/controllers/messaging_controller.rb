class MessagingController < ApplicationController
  def index
    if !params['session'].nil?
      #initial_text captures the very first sms or IM sent to tropo
      initial_text = params["session"]["initialText"]
      from = params["session"]["from"]
      network = from["network"]
      channel = from["channel"]
      from_id = from["id"] # this field contains IM login or phone number in case of incoming SMS

      if network == "SMS" || network == "JABBER"
        render :json => parse(initial_text)
      elsif network == "SIP" && channel == "VOICE"
        tropo = Tropo::Generator.new

          tropo.ask :name => 'zip', :bargein => true, :timeout => 60, :attempts => 2,
                      :say => [{:event => "timeout", :value => "Sorry, I did not hear anything."},
                     {:event => "nomatch:1 nomatch:2", :value => "Oops, that wasn't a five-digit zip code."},
                     {:value => "Please enter your zip code to search for volunteer opportunities in your area."}],
                      :choices => { :value => "[5 DIGITS]"}
          # Add a 'hangup' to the JSON response and set which resource to go to if a Hangup event occurs on Tropo
          tropo.on :event => 'hangup', :next => 'hangup'
          # Add an 'on' to the JSON response and set which resource to go when the 'ask' is done executing
          tropo.on :event => 'continue', :next => 'process_zip'

        render :json => tropo.response
      else
        render :json => Tropo::Generator.say("Unsupported operation")
      end

    else
      render :json => {:error => "There was an error"}
    end
  end

  def hangup
    render :json => Tropo::Generator.say(" Call complete ")
  end

  def process_zip
    render :json => Tropo::Generator.say(" Process zip ")
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