# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  chat                   :jsonb            not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[line]

  has_many :oauth_providers

  def self.from_omniauth(auth)
    case auth.provider
    when "line"
      Users::FindOrCreateFromLine.new(name: auth.info.name, line_id: auth.uid).run
    else
      nil
    end
  end

  def self.from_kamigo(params)
    return nil unless params[:platform_type].present?   &&
      params[:source_type].present?     &&
      params[:source_group_id].present? &&
      params[:source_user_id].present?

    Users::FindOrCreateFromLine.new(name:  params.dig(:profile, :displayName), line_id: params[:source_user_id]).run
  end

  def email_required?
    false
  end

  def password_required?
    false
  end

  def name
    oauth_providers.last&.name || ''
  end

  def reset_chat
    self.chat = []
    self.save
  end

  def save_chat(messages)
    self.chat = messages
    self.save
  end

  def load_chat
    chat
  end

end
