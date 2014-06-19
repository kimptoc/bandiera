module Bandiera
  class UserFeature < Sequel::Model
    # one_to_one :feature
    # one_to_one :user

    def before_create
      self.index = rand(1_000_000)
    end
  end
end
