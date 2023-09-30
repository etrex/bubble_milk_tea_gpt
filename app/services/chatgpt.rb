class Chatgpt
  def initialize(api_key, model, temperature: 0)
    @api_key = api_key
    @model = model
    @temperature = temperature
  end

  def self.gpt_3_5_turbo(api_key, temperature: 0)
    Chatgpt.new(api_key, 'gpt-3.5-turbo', temperature: temperature)
  end

  def self.gpt_4(api_key, temperature: 0)
    Chatgpt.new(api_key, 'gpt-4', temperature: temperature)
  end

  def chat(messages, functions: [])
    response = send_request(messages, functions: functions)
    body = response.body.force_encoding('UTF-8')
    json = JSON.parse(body)

    # 錯誤範例
    # {
    #   "error": {
    #     "message": "Incorrect API key provided: 123. You can find your API key at https://platform.openai.com/account/api-keys.",
    #     "type": "invalid_request_error",
    #     "param": null,
    #     "code": "invalid_api_key"
    #   }
    # }
    raise StandardError.new(json.dig('error', 'message')) if json.dig('error').present?

    # {
    #   "id": "chatcmpl-123",
    #   "object": "chat.completion",
    #   "created": 1677652288,
    #   "choices": [{
    #     "index": 0,
    #     "message": {
    #       "role": "assistant",
    #       "content": "\n\nHello there, how may I assist you today?",
    #     },
    #     "finish_reason": "stop"
    #   }],
    #   "usage": {
    #     "prompt_tokens": 9,
    #     "completion_tokens": 12,
    #     "total_tokens": 21
    #   }
    # }

    message = json.dig('choices', 0, 'message')
    content = message.dig('content')
    function_call = message.dig('function_call')
    # {
    #   "id"=>"chatcmpl-83RhnoiabVXVMaTNeMczU0daQq2Uk",
    #   "object"=>"chat.completion",
    #   "created"=>1695832175,
    #   "model"=>"gpt-3.5-turbo-0613",
    #   "choices"=>[{
    #     "index"=>0,
    #     "message"=>{
    #       "role"=>"assistant",
    #       "content"=>nil,
    #       "function_call"=>{
    #         "name"=>"get_current_weather",
    #         "arguments"=>"{\n  \"location\": \"Taipei\"\n}"
    #       }
    #     },
    #     "finish_reason"=>"function_call"
    #   }],
    #   "usage"=>{
    #     "prompt_tokens"=>109,
    #     "completion_tokens"=>17,
    #     "total_tokens"=>126
    #   }
    # }

    [message, content, function_call]
  end

  private

  def send_request(messages, functions: [])
    uri = URI.parse('https://api.openai.com/v1/chat/completions')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    body = {
      model: @model,
      messages: messages,
      temperature: @temperature,
    }
    body[:functions] = functions if functions.present?
    request.body = body.to_json

    req_options = {
      use_ssl: uri.scheme == 'https',
      open_timeout: 60, # opening a connection timeout
      read_timeout: 300 # reading one block of response timeout
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end