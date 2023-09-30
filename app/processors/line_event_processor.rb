class LineEventProcessor
  attr_accessor :request
  attr_accessor :form_authenticity_token

  def process(event)
    # 只處理文字訊息
    return if event.message_type != "text"

    text = event.message

    current_user = User.from_kamigo(event.platform_params)

    if text == "reset"
      current_user.reset_chat
      return {
        type: "text",
        text: "已重置對話"
      }
    end

    agent = Agent.new

    response = agent.chat(current_user, text)

    if response.is_a? String
      response = {
        type: "text",
        text: response
      }
    end

    if current_user&.orders&.last&.to_s.present?
      response = [
        response,
        {
          type: "text",
          text: "除錯資訊：\n" + current_user.orders.last.to_s
        }
      ]
    end

    response

    # elsif response.is_a? Hash
    #   # 如果是 Hash 先確認是不是 reverse route
    #   if response[:type] == "reverse_route"
    #     url = response[:url]
    #     http_method = response[:http_method]
    #     params = response[:params]
    #     reserve_route(url, http_method: http_method, request_params: event.platform_params.merge(params), format: :line)
    #   # 直接返回 LINE 的訊息格式
    #   else
    #     return response
    #   end
    # end
  end

  private

  def reserve_route(path, http_method: "GET", request_params: nil, format: nil)
    path = "/#{path}" unless path.start_with? "/"

    @request.request_method = http_method
    @request.path_info = path
    @request.format = format if format.present?
    @request.request_parameters = request_params if request_params.present?

    # req = Rack::Request.new
    # env = {Rack::RACK_INPUT => StringIO.new}

    res = Rails.application.routes.router.serve(@request)
    res[2].body if res[2].respond_to?(:body)
  end
end
