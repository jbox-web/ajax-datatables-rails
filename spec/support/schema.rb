# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string  :username
    t.string  :email
    t.string  :first_name
    t.string  :last_name
    t.integer :post_id
    t.integer :group_id

    t.timestamps null: false
  end

  create_table :groups, force: true do |t|
    t.string  :name
    t.integer :admin_id

    t.timestamps null: false
  end

end
