# == Schema Information
#
# Table name: items
#
#  id         :bigint           not null, primary key
#  ice        :string           not null
#  name       :string           not null
#  quantity   :string           not null
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
require 'rails_helper'

RSpec.describe Item, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
