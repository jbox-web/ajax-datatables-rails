# frozen_string_literal: true

require 'digest'

class User < ActiveRecord::Base
  def full_name
    "#{first_name} #{last_name}"
  end

  def email_hash
     Digest::SHA256.hexdigest email
  end
end
