# frozen_string_literal: true

class AddWeeklyPostSettingsToFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:fitness_challenges, :weekly_post_enabled)
      add_column :fitness_challenges, :weekly_post_enabled, :boolean, default: true, null: false
    end
    unless column_exists?(:fitness_challenges, :weekly_post_day)
      add_column :fitness_challenges, :weekly_post_day, :integer, default: 1, null: false
    end
    unless column_exists?(:fitness_challenges, :weekly_post_hour)
      add_column :fitness_challenges, :weekly_post_hour, :integer, default: 9, null: false
    end
  end

  def down
    remove_column :fitness_challenges, :weekly_post_enabled if column_exists?(:fitness_challenges, :weekly_post_enabled)
    remove_column :fitness_challenges, :weekly_post_day if column_exists?(:fitness_challenges, :weekly_post_day)
    remove_column :fitness_challenges, :weekly_post_hour if column_exists?(:fitness_challenges, :weekly_post_hour)
  end
end
