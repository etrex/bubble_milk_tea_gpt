class HomeController < ApplicationController
  def reset
    current_user.reset_chat
    current_user.orders.destroy_all

    render json:  { type: "text", text: "已重置對話" }
  end
end
