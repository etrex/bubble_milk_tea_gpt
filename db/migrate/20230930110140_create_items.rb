class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.references :order, null: false, foreign_key: true
      t.string :name, null: false
      t.string :size, null: false
      t.string :suger, null: false
      t.string :ice, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
