# frozen_string_literal: true

class Group < ActiveRecord::Base
  belongs_to :admin, class_name: 'User'
  has_many :users
end
