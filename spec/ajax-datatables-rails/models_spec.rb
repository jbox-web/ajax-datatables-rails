require 'spec_helper'

describe AjaxDatatablesRails::Models do
  let(:models){ AjaxDatatablesRails::Models.new }

  it "is configurable" do
    models.user = User
    expect(models.user).to eq(User)
  end
end
