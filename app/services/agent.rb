class Agent
  def initialize
    @system_message = {
      role: "system",
      content: '
珍奶店販售的商品：

珍珠奶茶
狀態：販售中
大小選項：大杯、中杯、小杯
甜度選項：無糖、微糖、半糖、全糖
溫度選項：去冰、微冰、少冰、正常冰
價格：50 元

紅茶
狀態：販售中
大小選項：大杯、中杯、小杯
甜度選項：無糖、微糖、半糖、全糖
溫度選項：去冰、微冰、少冰、正常冰
價格：30 元

其他飲料
狀態：已售完

你扮演飲料店熱情活潑的店員，負責接待客人進行點餐，以下是一些注意事項：

- 接待點餐時你需要確認客人的所有選項
- 基於禮貌，你一次只能詢問客人一個問題
- 你可以用推薦的方式說服客人選擇我們有提供的選項
- 在訂購餐點前，應條列訂單內容跟客人確認
- 絕對不能賣出我們沒有提供的商品
- 對於店家最有利的商品組合是大杯珍珠奶茶微糖微冰，儘可能推銷客人點這個
'
    }
    # @gpt = Chatgpt.gpt_3_5_turbo(ENV['OPENAI_API_KEY'], temperature: 0)
    @gpt = Chatgpt.gpt_4(ENV['OPENAI_API_KEY'], temperature: 0)
    @functions = functions
  end

  def chat(user, message)
    need_reset_chat = false
    history_messages = user.load_chat
    history_messages << {
      role: "user",
      content: message
    }
    reply_message, content, function_call = @gpt.chat([@system_message] + history_messages, functions: @functions)

    while function_call.present?
      function_call_result = call_function(user, function_call)
      need_reset_chat = true if function_call.dig("name") == "end_session"

      history_messages << reply_message
      history_messages << {
        role: "function",
        name: function_call["name"],
        content: function_call_result
      }

      reply_message, content, function_call = @gpt.chat([@system_message] + history_messages, functions: @functions)
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
    return content
  end

  private

  def call_function(user, function_call)
    case function_call.dig("name")
    when "add_item"
      params = function_call.dig("parameters")
      item = Item.create(
        order: user.orders.last,
        name: params.dig("name"),
        quantity: params.dig("quantity")
        size: params.dig("size"),
        suger: params.dig("suger"),
        ice: params.dig("ice"),
      )
      "確認訂購餐點成功，請複誦客戶餐點，並詢問用戶要不要繼續點別的。"
    when "end_session"
      "對話已結束，應在此時回覆用戶一些結束對話的訊息。"
    else
      "此功能目前維修中"
    end
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
        "name": "add_item",
        "description": "請詢問清楚用戶點餐的內容後再使用此方法",
        "parameters": {
            "type": "object",
            "properties": {
              "name": {"type": "string", "enum": ["珍珠奶茶", "紅茶"]},
              "quantity": {"type": "integer"},
              "size": {"type": "string", "enum": ["大杯", "中杯", "小杯"]},
              "suger": {"type": "string", "enum": ["無糖", "微糖", "半糖", "少糖", "全糖"]},
              "ice": {"type": "string", "enum": ["去冰", "微冰", "半冰", "少冰", "全冰"]},
            },
            "required": ["name", "quantity", "size", "suger", "ice"],
        },
      },
      {
        "name": "remove_item",
        "description": "移除購物車內的商品",
        "parameters": {
            "type": "object",
            "properties": {
              "id": {"type": "integer"},
            },
            "required": ["id"],
        },
      },
      {
        "name": "show_cart",
        "description": "使用條列式的方式展示購物車內容",
        "parameters": {
          "type": "object",
          "properties": {}
        },
      },
      {
        "name": "checkout",
        "description": "結帳",
        "parameters": {
          "type": "object",
          "properties": {}
        },
      },
      {
        "name": "end_session",
        "description": "完成點餐後結束對話",
        "parameters": {
          "type": "object",
          "properties": {}
        },
      }
    ]
  end
end
