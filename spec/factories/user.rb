FactoryGirl.define do
  factory :user do |f|
    f.username   { Faker::Internet.user_name }
    f.email      { Faker::Internet.email }
    f.first_name { Faker::Name.first_name }
    f.last_name  { Faker::Name.last_name }
    f.post_id    { ((1..100).to_a).sample }
  end
end
