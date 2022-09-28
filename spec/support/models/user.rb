# frozen_string_literal: true

class User < ActiveRecord::Base
  belongs_to :group, optional: true
  has_many :admin_groups, foreign_key: :admin_id

  def full_name
    "#{first_name} #{last_name}"
  end
end
