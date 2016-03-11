ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :username
    t.string :email
    t.string :first_name
    t.string :last_name

    t.timestamps null: false
  end

  create_table :addresses, :force => true do |t|
    t.string :address_line1
    t.string :address_line2
    t.string :city
    t.string :zip_code
    t.string :state
    t.string :country

    t.timestamps null: false
  end

  create_table :purchased_orders, :force => true do |t|
    t.string :foo
    t.string :bar

    t.timestamps null: false
  end

  create_table :statistics_requests, :force => true do |t|
    t.string :baz

    t.timestamps null: false
  end

  create_table :statistics_sessions, :force => true do |t|
    t.string :foo
    t.integer :bar

    t.timestamps null: false
  end
end
