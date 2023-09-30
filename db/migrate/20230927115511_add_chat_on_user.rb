class AddChatOnUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :chat, :jsonb, default: [], null: false
  end
end
