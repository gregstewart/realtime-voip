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

        tropo.ask :name => 'greet', :bargein => true, :timeout => 60, :attempts => 2,
                    :say => [{:event => "timeout", :value => " Sorry, I did not hear anything. "},
                   {:event => "nomatch:1 nomatch:2", :value => " Oops, that wasn't a valid selection. "},
                   {:value => " Hello. If you are calling to retrieve an Australian valuation press 1. To retrieve a UK valuation press 2"}],
                    :choices => { :value => "australia(1, australia), uk(2, uk)"}

        # Add a 'hangup' to the JSON response and set which resource to go to if a Hangup event occurs on Tropo
        tropo.on :event => 'hangup', :next => 'messaging/hangup'
        # Add an 'on' to the JSON response and set which resource to go when the 'ask' is done executing
        tropo.on :event => 'continue', :next => 'messaging/prompt_for_val_id'

        render :json => tropo.response
      else
        render :json => Tropo::Generator.say("Unsupported operation")
      end

    else
      render :json => {:error => "There was an error"}
    end
  end

  def prompt_for_val_id
    tropo = Tropo::Generator.new

    
    if params["result"]["actions"]["value"].to_s == "australia"
      message = " Please enter your realtime val eye dee followed by the hash key "
    else
      message = " Uk valuations are currently not supported "
    end
    tropo.ask :name => 'prompt_for_val_id', :bargein => true, :timeout => 60, :attempts => 2,
                :say => [{:event => "timeout", :value => " Sorry, I did not hear anything. "},
               {:event => "nomatch:1", :value => "Oops, that wasn't a valid val eye dee. "},
               {:value => message}],
                :choices => {:value => "[DIGITS]", :mode => "dtmf", :terminator => "#"}
    # Add a 'hangup' to the JSON response and set which resource to go to if a Hangup event occurs on Tropo
    tropo.on :event => 'hangup', :next => 'hangup'
    # Add an 'on' to the JSON response and set which resource to go when the 'ask' is done executing
    tropo.on :event => 'continue', :next => 'retrieve_val'

    render :json => tropo.response
  end

  def hangup
    render :json => Tropo::Generator.say(" Call complete ")
  end

  def retrieve_val
    number_helper = Object.new.extend(ActionView::Helpers::NumberHelper)
    result = Realtime.fetch(params["result"]["actions"]["value"])
    
    render :json => Tropo::Generator.say(" Valuation retrieved. Valuation address: #{result[:address].to_s}. Confidence score is #{result[:cl].to_s}. Valuation of #{number_helper.number_to_human(result[:valuation])} dollars")
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