
class PagesController < ApplicationController
  def home
    @app_key=Settings.tropo_key
    respond_to do |format|
      format.html
    end
  end

end
