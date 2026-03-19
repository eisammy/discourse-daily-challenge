# frozen_string_literal: true

class DailyCheckIn < ActiveRecord::Base
  self.table_name = "daily_check_ins"

  belongs_to :challenge, class_name: "DailyChallenge", foreign_key: :challenge_id
  belongs_to :user
  belongs_to :post, optional: true

  validates :challenge_id, presence: true
  validates :user_id, presence: true
  validates :check_in_date, presence: true
  validates :check_in_date,
            uniqueness: {
              scope: %i[challenge_id user_id],
              message: "already checked in on this date",
            }
end
