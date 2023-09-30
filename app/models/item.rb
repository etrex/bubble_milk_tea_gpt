# == Schema Information
#
# Table name: items
#
#  id         :bigint           not null, primary key
#  ice        :string           not null
#  name       :string           not null
#  quantity   :integer          not null
#  size       :string           not null
#  suger      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :bigint           not null
#
# Indexes
#
#  index_items_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class Item < ApplicationRecord
  belongs_to :order
  validates :name, :size, :suger, :ice, :quantity, presence: true
  # quantity between 1~10
  validates :quantity, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  # name in ["珍珠奶茶", "紅茶"]
  validates :name, inclusion: { in: ["珍珠奶茶", "紅茶"] }
  # size in ["大杯", "中杯", "小杯"]
  validates :size, inclusion: { in: ["大杯", "中杯", "小杯"] }
  # suger in ["無糖", "微糖", "半糖", "少糖", "全糖"]
  validates :suger, inclusion: { in: ["無糖", "微糖", "半糖", "全糖"] }
  # ice in ["去冰", "微冰", "半冰", "少冰", "全冰"]
  validates :ice, inclusion: { in: ["去冰", "微冰", "少冰", "正常冰"] }

  def unit_price
    case name
    when "珍珠奶茶"
      case size
      when "大杯"
        50
      when "中杯"
        40
      when "小杯"
        30
      else
        0
      end
    when "紅茶"
      case size
      when "大杯"
        40
      when "中杯"
        30
      when "小杯"
        20
      else
        0
      end
    else
      0
    end
  end

  def price
    unit_price.to_i * quantity.to_i
  end

  def to_s
    "item ##{id}: #{name} #{size} #{suger} #{ice}, $#{unit_price} x #{quantity} = $#{price}"
  end
end
