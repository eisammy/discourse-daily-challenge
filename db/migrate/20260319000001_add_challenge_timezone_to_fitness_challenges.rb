# frozen_string_literal: true

class AddChallengeTimezoneToFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:fitness_challenges, :challenge_timezone)
      add_column :fitness_challenges, :challenge_timezone, :string, null: false, default: "UTC"
    end
  end

  def down
    remove_column :fitness_challenges, :challenge_timezone if column_exists?(:fitness_challenges, :challenge_timezone)
  end
end
