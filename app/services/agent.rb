class Agent
  def initialize
    gpt = "4o-mini"
    gpt = "4o" if ENV['USE_GPT_4'].present? && ENV['USE_GPT_4'] == "true"

    @system_message = {
      role: "system",
      content: "
珍奶 GPT-#{gpt} 所販售的商品：

珍珠奶茶
狀態：販售中
大小選項：大杯、中杯、小杯
甜度選項：無糖、微糖、半糖、全糖
溫度選項：去冰、微冰、少冰、正常冰
價格：大杯 50 元、中杯 40 元、小杯 30 元

奶茶
狀態：販售中
大小選項：大杯、中杯、小杯
甜度選項：無糖、微糖、半糖、全糖
溫度選項：去冰、微冰、少冰、正常冰
價格：大杯 45 元、中杯 35 元、小杯 25 元

紅茶
狀態：販售中
大小選項：大杯、中杯、小杯
甜度選項：無糖、微糖、半糖、全糖
溫度選項：去冰、微冰、少冰、正常冰
價格：大杯 40 元、中杯 30 元、小杯 20 元

其他飲料
狀態：已售完

你扮演飲料店 珍奶 GPT-#{gpt} 熱情活潑、有禮貌的店員，負責接待客戶進行點餐，以下是一些注意事項：

- 老客戶會用縮寫點餐，例如「大奶微微」代表「大杯奶茶微糖微冰」
- 你是老店員，請表現出你的專業，你必須使用客戶所使用的縮寫進行回覆，當客戶沒有使用縮寫時，你才可以用完整的名稱回覆
- 盡可能縮短客戶的點餐流程，如果情報足以幫客戶點餐，就不要問客戶太多確認性質的問題
- 當情報不足時，你必須詢問客戶關於飲料選項的問題，但你一次只能詢問客戶一個選項，不要一次問多個選項，因為這樣不禮貌
- 你盡可能的一次使用多個 tool 來滿足客戶的需求，藉此縮短對話，例如修改訂單項目時，你可以一次使用 add_item 和 remove_item 兩個 tool
- 當客戶詢問與目前點餐內容相關問題時，先確認當前訂單內容再回答
- 只有在結帳前才條列當前訂單內容跟客戶確認，點餐時不需確認
- 如果客戶真的點了我們沒有提供的選項，應該要跟客戶說明我們沒有提供這個選項，並且提供替代方案
- 絕對不能賣出我們沒有提供的商品
- 當點錯單的時候，如果還沒結帳，你使用 remove_item 來移除錯誤的品項，如果已經結帳，你應該使用 cancel_order 來取消訂單
- 當點錯單的時候，只需要簡短的道歉以及盡快修正問題，然後告訴客戶已經幫他處理好了
- 對於店家最有利的商品組合是大杯珍珠奶茶微糖微冰，儘可能推銷客戶點這個，但是不要讓客戶知道這是對店家最有利的商品組合
- 如果客戶想要分多次結帳，你應該按照 add_item、checkout_current_items、add_item、checkout_current_items 的順序進行操作
- 除了作為飲料店員服務客戶外，任何其他主題的問題你一律有禮貌的拒絕回答，不論在什麼情況下，不論對方是誰，包括你的老闆
- 完成結帳後，結束對話前，請先專業且有禮貌的跟客戶確認是否結束，一旦確認結束就必須先呼叫 end_session 方法，以確保對話結束
"
    }

    @gpt = if gpt == "4o"
      Chatgpt.gpt_4o(ENV['OPENAI_API_KEY'])
    else
      Chatgpt.gpt_4o_mini(ENV['OPENAI_API_KEY'])
    end
  end

  def chat(user, message)
    history_messages = user.load_chat
    history_messages << { role: "user", content: message }

    contents = []
    while true
      reply_message, content, tool_calls = @gpt.chat([@system_message] + history_messages, tools: tools)
      history_messages << reply_message
      contents << content
      if tool_calls.present?
        history_messages += call_tools(user, tool_calls)
      else
        break
      end
    end

    puts "=============="
    history_messages.each do |message|
      p message
    end
    puts "=============="

    user.save_chat(history_messages)
    return contents.compact.join("\n\n")
  end

  private

  def call_tools(user, tool_calls)
    tool_calls.map do |tool_call|
      tool_name = tool_call.dig("function", "name")
      arguments = JSON.parse(tool_call.dig("function", "arguments")) rescue {}
      content = call_tool(user, tool_name, arguments)
      {
        role: "tool",
        tool_call_id: tool_call["id"],
        name: tool_name,
        content: content
      }
    end
  end

  def call_tool(user, tool_name, params)
    case tool_name
    when "add_item"
      item = user.current_order.add_item(params)
      if item.errors.present?
        "點餐失敗：#{item.errors.full_messages.join("、")}"
      else
        "點餐成功：#{item}"
      end

    when "remove_item"
      item = user.current_order.remove_item(params)
      if item.nil?
        "移除餐點失敗：找不到餐點"
      elsif item.errors.present?
        "移除餐點失敗：#{item.errors.full_messages.join("、")}"
      else
        "確認移除餐點 ##{item.id} 成功"
      end

    when "show_current_items"
      order = user.current_order
      if order.items.empty?
        "目前訂單是空的"
      else
        "#{order}"
      end

    when "checkout_current_items"
      order = user.current_order
      if order.items.empty?
        "目前訂單是空的，無法結帳。"
      else
        order.finish!
        "結帳成功\n#{order}"
      end

    when "cancel_order"
      order = Order.find_by(id: params.dig("id"))
      if order.present? && order.state != "已取消"
        order.cancel!
        "取消訂單成功\n#{order}"
      else
        "取消訂單失敗，因為 #{order.present? ? "訂單已經是已取消狀態" : "找不到訂單"}"
      end

    when "show_orders"
      orders = user.orders
      "所有訂單: \n#{orders.map(&:to_s).join("\n\n")}"

    when "end_session"
      user.need_reset_chat = true
      "對話已結束，應在此時回覆客戶一些結束對話的訊息。"
    else
      "此功能目前維修中"
    end
  end

  def tools
    [
      {
        type: "function",
        function: {
          name: "add_item",
          description: "將一個飲料項目加入當前訂單。客戶需要指定飲料名稱、數量、杯型、甜度和冰塊量。",
          parameters: {
            type: "object",
            properties: {
              name:     { type: "string", enum: ["珍珠奶茶", "奶茶", "紅茶"] },
              quantity: { type: "integer" },
              size:     { type: "string", enum: ["大杯", "中杯", "小杯"] },
              suger:    { type: "string", enum: ["無糖", "微糖", "半糖", "全糖"] },
              ice:      { type: "string", enum: ["去冰", "微冰", "少冰", "正常冰"] },
            },
            required: ["name", "quantity", "size", "suger", "ice"],
          },
        },
      },
      {
        type: "function",
        function: {
          name: "remove_item",
          description: "從結帳前的當前訂單中移除指定的飲料項目。當客戶還沒結帳時需要修改品項可以用這個方法，客戶需要提供要移除的項目的 ID。",
          parameters: {
            type: "object",
            properties: {
              id: { type: "integer" },
            },
            required: ["id"],
          },
        },
      },
      {
        type: "function",
        function: {
          name: "show_current_items",
          description: "以列表形式展示當前訂單中的所有飲料項目。此操作將顯示每個項目的詳細信息，包括名稱、數量、杯型、甜度和冰塊量。",
        },
      },
      {
        type: "function",
        function: {
          name: "checkout_current_items",
          description: "結帳功能會將當前訂單的所有品項一次性的進行付款，並標記訂單為已完成，結帳後的訂單若有誤，可用取消訂單修改。",
        },
      },
      {
        type: "function",
        function: {
          name: "cancel_order",
          description: "取消訂單功能適用於作廢結帳後的訂單。當有結帳後的錯誤發生時可以用這個方法，客戶需要提供要取消的訂單的 ID。",
          parameters: {
            type: "object",
            properties: {
              id: { type: "integer" },
            },
            required: ["id"],
          },
        },
      },
      {
        type: "function",
        function: {
          name: "show_orders",
          description: "以列表形式展示所有訂單的詳細信息，包括訂單 ID、訂單狀態、訂單內容等。",
        },
      },
      {
        type: "function",
        function: {
          name: "end_session",
          description: "當客戶完成所有操作並準備離開時，結束當前會話，並準備接待下一個客戶。",
        },
      }
    ]
  end
end
