class GitlabAgent
  def initialize
    @system_message = {
      role: "system",
      content: "你是一個聰明的個人助理，你用正體中文回答我的問題。任何數學問題，你不能自己計算結果，你必須使用工具，當你回答問題之前，你始終確認答案是否正確。"
    }

    @gpt = AzureChatgpt.new(ENV['AZURE_OPENAI_KEY'], temperature: 0)
    @functions = functions
  end

  def chat(user, message)
    need_reset_chat = false
    history_messages = user.load_chat
    history_messages << {
      role: "user",
      content: message
    }
    contents = []
    reply_message, content, function_call = @gpt.chat([@system_message] + history_messages, functions: @functions)
    contents << content

    while function_call.present?
      function_call_result = call_function(user, function_call)
      need_reset_chat = true if function_call.dig("name") == "end_session"

      # debugger
      reply_message["content"] = "" if reply_message["content"].nil?
      history_messages << reply_message
      history_messages << {
        role: "function",
        name: function_call["name"],
        content: function_call_result
      }

      reply_message, content, function_call = @gpt.chat([@system_message] + history_messages, functions: @functions)
      contents << content
    end

    history_messages << reply_message
    puts "=============="
    history_messages.each do |message|
      p message
    end
    puts "=============="

    if need_reset_chat
      user.reset_chat
    else
      user.save_chat(history_messages)
    end
    return contents.compact.join("\n\n")
  end

  private

  def call_function(user, function_call)
    arguments = JSON.parse(function_call.dig("arguments"))
    case function_call.dig("name")
    when 'math_calculate'
      math_calculate(arguments)
    else
      "此功能目前維修中"
    end
  rescue StandardError => e
    puts e.message
    e.message
  end

  def math_calculate(arguments)
    # 簡單的範例
    eval(arguments['formula']).to_s
  end

  # function 範例
  # {
  #   "name": "get_current_weather",
  #   "description": "Get the current weather in a given location",
  #   "parameters": {
  #       "type": "object",
  #       "properties": {
  #           "location": {
  #               "type": "string",
  #               "description": "The city and state, e.g. San Francisco, CA",
  #           },
  #           "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
  #       },
  #       "required": ["location"],
  #   },
  # }
  def functions
    [
      {
        name: "math_calculate",
        description: "輸入一個數學的計算式，回傳計算完成的結果",
        parameters: {
          type: "object",
          properties: {
            formula: {
              type: "string",
              description: "一個可以被 ruby eval 執行的數學的計算式字串, 例如次方應該用 ** 而不是 ^"
            }
          },
          required: ["formula"]
        }
      }
    ]
  end
end
