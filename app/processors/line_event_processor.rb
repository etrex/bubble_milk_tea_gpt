class LineEventProcessor
  attr_accessor :request
  attr_accessor :form_authenticity_token

  def process(event)
    return disable_message if ENV['ENABLE_GPT'] != "true" # 關閉 GPT
    return if event.message_type != "text" # 只處理文字訊息

    current_user = User.from_kamigo(event.platform_params)

    agent = Agent.new
    response = agent.chat(current_user, event.message)
    response = text_message(response) if response.is_a? String

    if ENV['DEBUG'] == "true" && current_user.chat.present?
      response = debug_message(current_user, message)
    end

    response
  end

  private

  def disable_message
    Kamiflex.json(self) do
      bubble do
        body do
          text "目前未開放 GPT 的使用，如有需要請聯絡卡米哥", wrap: true
          url_button "聯絡卡米哥", "https://www.facebook.com/the.kamiger", style: "primary", margin: "lg"
        end
      end
    end
  end

  def text_message(text)
    { type: "text", text: text }
  end

  def debug_message(current_user, message)
    [
      message,
      {
        type: "text",
        text: "【除錯資訊】 歷史訊息數量 #{current_user.chat.count}"
      }
    ]
  end
end
