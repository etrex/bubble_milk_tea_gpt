class Chatgpt
  def initialize(api_key, model, temperature: 0.3)
    @api_key = api_key
    @model = model
    @temperature = temperature
  end

  def self.gpt_4o_mini(api_key, temperature: 0.3)
    Chatgpt.new(api_key, 'gpt-4o-mini', temperature: temperature)
  end

  def self.gpt_4o(api_key, temperature: 0.3)
    Chatgpt.new(api_key, 'gpt-4o', temperature: temperature)
  end

  def chat(messages, tools: [])
    response = send_request(messages, tools: tools)
    body = response.body.force_encoding('UTF-8')
    json = JSON.parse(body)

    raise StandardError.new(json.dig('error', 'message')) if json.dig('error').present?

    message = json.dig('choices', 0, 'message')
    content = message.dig('content')
    tool_calls = message.dig('tool_calls')

    [message, content, tool_calls]
  end

  private

  def send_request(messages, tools: [])
    uri = URI.parse('https://api.openai.com/v1/chat/completions')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"

    body = {
      model: @model,
      messages: messages,
      temperature: @temperature,
    }
    body[:tools] = tools if tools.present?

    request.body = body.to_json

    req_options = {
      use_ssl: uri.scheme == 'https',
      open_timeout: 30, # opening a connection timeout
      read_timeout: 30 # reading one block of response timeout
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
