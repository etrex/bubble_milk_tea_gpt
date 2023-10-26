class AzureChatgpt
  def initialize(api_key, temperature: 0)
    @api_key = api_key
    @temperature = temperature
  end

  def chat(messages, functions: [])
    response = send_request(messages, functions: functions)
    body = response.body.force_encoding('UTF-8')
    json = JSON.parse(body)

    raise StandardError.new(json.dig('error', 'message')) if json.dig('error').present?

    message = json.dig('choices', 0, 'message')
    content = message.dig('content')
    function_call = message.dig('function_call')

    [message, content, function_call]
  end

  private

  def send_request(messages, functions: [])
    uri = URI.parse('https://esopenaipoc.openai.azure.com/openai/deployments/9gtest/chat/completions?api-version=2023-07-01-preview')
    request = Net::HTTP::Post.new(uri, {
      'Content-Type' => 'application/json',
      'api-key' => @api_key
    })

    body = {
      model: "gpt-3.5-turbo-0613",
      function_call: "auto",
      messages: messages,
      temperature: @temperature,
    }
    body[:functions] = functions if functions.present?
    request.body = body.to_json

    puts "=============="
    puts request.body
    puts "=============="

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