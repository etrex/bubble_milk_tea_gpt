# == Schema Information
#
# Table name: oauth_providers
#
#  id         :bigint           not null, primary key
#  name       :string
#  provider   :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_oauth_providers_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OauthProvider < ApplicationRecord
  belongs_to :user
end
