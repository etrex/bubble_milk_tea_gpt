class Agent
  def initialize
    @system_message = {
      role: "system",
      content: '
珍奶 GPT 所販售的商品：

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

你扮演飲料店 珍奶 GPT 熱情活潑的店員，負責接待客人進行點餐，以下是一些注意事項：

- 接待點餐時你需要確認客人的所有選項
- 基於禮貌，你一次只能詢問客人一個問題
- 如果客人點了我們沒有提供的選項，應該要跟客人說明我們沒有提供這個選項，並且提供替代方案
- 在訂購餐點前，應條列訂單內容跟客人確認
- 絕對不能賣出我們沒有提供的商品
- 對於店家最有利的商品組合是大杯珍珠奶茶微糖微冰，儘可能推銷客人點這個
'
    }
    @gpt = Chatgpt.gpt_3_5_turbo(ENV['OPENAI_API_KEY'], temperature: 0)
    # @gpt = Chatgpt.gpt_4(ENV['OPENAI_API_KEY'], temperature: 0)
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
    params = JSON.parse(function_call.dig("arguments"))
    case function_call.dig("name")
    when "add_item"
      item = user.current_order.add_item(params)
      if item.errors.present?
        "點餐失敗：#{item.errors.full_messages.join("、")}"
      else
        "點餐成功：#{item}"#\n請複誦客戶餐點，並詢問用戶要不要繼續點別的。"
      end
    when "remove_item"
      item = user.current_order.remove_item(params)
      if item.nil?
        "移除餐點失敗：找不到餐點"
      elsif item.errors.present?
        "移除餐點失敗：#{item.errors.full_messages.join("、")}"
      else
        "確認移除餐點成功"#，請複誦客戶餐點，並詢問用戶要不要繼續點別的。"
      end
    when "show_cart"
      order = user.current_order
      if order.items.empty?
        "目前購物車是空的"#，請詢問用戶要不要繼續點別的。"
      else
        "#{order}"#\n請詢問用戶是否確定結帳。"
      end
    when "checkout"
      order = user.current_order
      if order.items.empty?
        "目前購物車是空的，無法結帳。"
      else
        order.finish!
        "結帳成功\n#{order}"#，結帳後應結束對話。"
      end
    when "cancel_order"
      order = Order.find_by(id: params.dig("id"))
      if order.present? && order.state != "已取消"
        order.cancel!
        "取消訂單成功\n#{order}"
      else
        "取消訂單失敗，因為 #{order.present? ? "訂單已經是已取消狀態" : "找不到訂單"}"
      end
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
        "description": "加入商品到購物車，應詢問清楚用戶點餐的內容後再使用此方法",
        "parameters": {
            "type": "object",
            "properties": {
              "name": {"type": "string", "enum": ["珍珠奶茶", "紅茶"]},
              "quantity": {"type": "integer"},
              "size": {"type": "string", "enum": ["大杯", "中杯", "小杯"]},
              "suger": {"type": "string", "enum": ["無糖", "微糖", "半糖", "全糖"]},
              "ice": {"type": "string", "enum": ["去冰", "微冰", "少冰", "正常冰"]},
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
        "description": "將購物車內的所有商品結帳，結帳後購物車將清空",
        "parameters": {
          "type": "object",
          "properties": {}
        },
      },
      {
        "name": "cancel_order",
        "description": "作廢指定的訂單",
        "parameters": {
          "type": "object",
          "properties": {
            "id": {"type": "integer"},
          },
          "required": ["id"],
        },
      },
      {
        "name": "end_session",
        "description": "結束對話",
        "parameters": {
          "type": "object",
          "properties": {}
        },
      }
    ]
  end
end
