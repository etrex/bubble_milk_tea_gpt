require 'rails_helper'

RSpec.describe "items/edit", type: :view do
  let(:item) {
    Item.create!(
      name: "MyString",
      size: "MyString",
      suger: "MyString",
      ice: "MyString",
      quantity: 1,
      order: nil
    )
  }

  before(:each) do
    assign(:item, item)
  end

  it "renders the edit item form" do
    render

    assert_select "form[action=?][method=?]", item_path(item), "post" do

      assert_select "input[name=?]", "item[name]"

      assert_select "input[name=?]", "item[size]"

      assert_select "input[name=?]", "item[suger]"

      assert_select "input[name=?]", "item[ice]"

      assert_select "input[name=?]", "item[quantity]"

      assert_select "input[name=?]", "item[order_id]"
    end
  end
end
