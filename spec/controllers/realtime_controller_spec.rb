require 'spec_helper'

describe RealtimeController do
  render_views

  describe "Get 'show'" do

    it "should be successful" do
      get 'show'
      response.should be_success
    end

  end
end
