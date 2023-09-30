require 'rails_helper'

RSpec.describe "items/show", type: :view do
  before(:each) do
    assign(:item, Item.create!(
      name: "Name",
      size: "Size",
      suger: "Suger",
      ice: "Ice",
      quantity: 2,
      order: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Size/)
    expect(rendered).to match(/Suger/)
    expect(rendered).to match(/Ice/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
