# frozen_string_literal: true

class User < ActiveRecord::Base
  def full_name
    "#{first_name} #{last_name}"
  end
end
