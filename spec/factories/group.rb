# frozen_string_literal: true

FactoryBot.define do
  factory :group do |f|
    f.name   { Faker::Team.name }
    f.admin  { build(:user) }
  end
end
