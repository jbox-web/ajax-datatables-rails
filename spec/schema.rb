ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string  :username
    t.integer :status

    t.timestamps
  end

  create_table :user_data, :force => true do |t|
    t.string :address

    t.timestamps
  end

  create_table :purchased_orders, :force => true do |t|
    t.string :foo
    t.string :bar

    t.timestamps
  end

  create_table :statistics_requests, :force => true do |t|
    t.string :baz

    t.timestamps
  end

  create_table :statistics_sessions, :force => true do |t|
    t.string :foo
    t.integer :bar

    t.timestamps
  end
end
