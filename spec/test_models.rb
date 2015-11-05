class User < ActiveRecord::Base
  enum status: [:disabled, :active]
end

class UserData < ActiveRecord::Base
  self.table_name = "user_data"
end

class PurchasedOrder < ActiveRecord::Base
end

module Statistics
  def self.table_name_prefix
    "statistics_"
  end
end

class Statistics::Request < ActiveRecord::Base
end

class Statistics::Session < ActiveRecord::Base
end
