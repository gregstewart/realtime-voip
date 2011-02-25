require 'yaml'

class PagesController < ApplicationController
  def home

    @app_key = APP_CONFIG['tropo']
    respond_to do |format|
      format.html
    end
  end

end
