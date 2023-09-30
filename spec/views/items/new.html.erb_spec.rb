require 'rails_helper'

RSpec.describe "items/new", type: :view do
  before(:each) do
    assign(:item, Item.new(
      name: "MyString",
      size: "MyString",
      suger: "MyString",
      ice: "MyString",
      quantity: 1,
      order: nil
    ))
  end

  it "renders new item form" do
    render

    assert_select "form[action=?][method=?]", items_path, "post" do

      assert_select "input[name=?]", "item[name]"

      assert_select "input[name=?]", "item[size]"

      assert_select "input[name=?]", "item[suger]"

      assert_select "input[name=?]", "item[ice]"

      assert_select "input[name=?]", "item[quantity]"

      assert_select "input[name=?]", "item[order_id]"
    end
  end
end
