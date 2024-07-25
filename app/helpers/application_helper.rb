module ApplicationHelper
  def 服務名稱
    if ENV["USE_GPT_4"].present? && ENV["USE_GPT_4"] == "true"
      "珍奶 GPT-4o"
    else
      "珍奶 GPT-4o-mini"
    end
  end
end
