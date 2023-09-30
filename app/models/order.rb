# == Schema Information
#
# Table name: orders
#
#  id         :bigint           not null, primary key
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_orders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  validates :state, presence: true
  validates :state, inclusion: { in: ["進行中", "已完成", "已取消"] }
  validates :user_id, presence: true

  # state 的預設值是 "進行中"
  after_initialize :set_default_state, if: :new_record?

  def set_default_state
    self.state ||= "進行中"
  end

  def total_price
    items.sum(&:price)
  end

  def total_quantity
    items.sum(&:quantity)
  end

  def add_item(params)
    items.create(
      name: params.dig("name"),
      quantity: params.dig("quantity"),
      size: params.dig("size"),
      suger: params.dig("suger"),
      ice: params.dig("ice"),
    )
  end

  def remove_item(params)
    items.find_id(id: params.dig("id"))&.destroy
  end

  def finish!
    update_state("已完成")
  end

  def cancel!
    update_state("已取消")
  end

  def to_s
    if items.empty?
      "訂單id: #{id}，狀態: #{state}, 目前是空的"
    else
      "訂單id: #{id}，狀態: #{state}，總價: #{total_price}\n\n#{items.map(&:to_s).join("\n")}"
    end
  end

  private

  def update_state(state)
    update(state: state)
  end
end
