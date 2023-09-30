class CreateOauthProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_providers do |t|
      t.string :provider
      t.string :name
      t.string :uid
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
