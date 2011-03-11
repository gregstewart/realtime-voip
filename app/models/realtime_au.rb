class RealtimeAu < Realtime
  # To change this template use File | Settings | File Templates.
  def initialize()
    super
  end

  def self.get_valuation(realtime_id)
    @response, @data = fetch(realtime_id)
    
    if @response.code == 200.to_s
      parse_response(@data)
    else
      {:message => "Sorry unable to connect to API"}
    end

  end

  def self.parse_response(xml)
    @outcome, @message = has_errors(xml)
    if !@outcome
      parse_xml(xml)
    else
      {:message => @message}
    end

  end

end