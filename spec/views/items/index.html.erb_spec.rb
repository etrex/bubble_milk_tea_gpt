require 'rails_helper'

RSpec.describe "items/index", type: :view do
  before(:each) do
    assign(:items, [
      Item.create!(
        name: "Name",
        size: "Size",
        suger: "Suger",
        ice: "Ice",
        quantity: 2,
        order: nil
      ),
      Item.create!(
        name: "Name",
        size: "Size",
        suger: "Suger",
        ice: "Ice",
        quantity: 2,
        order: nil
      )
    ])
  end

  it "renders a list of items" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Size".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Suger".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Ice".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
