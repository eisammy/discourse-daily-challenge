# frozen_string_literal: true

class AddBadgeFieldsToFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    add_column :fitness_challenges, :award_badge, :boolean, default: true, null: false unless column_exists?(:fitness_challenges, :award_badge)
    add_column :fitness_challenges, :badge_name, :string unless column_exists?(:fitness_challenges, :badge_name)
    add_column :fitness_challenges, :badge_id, :integer unless column_exists?(:fitness_challenges, :badge_id)
  end

  def down
    remove_column :fitness_challenges, :award_badge if column_exists?(:fitness_challenges, :award_badge)
    remove_column :fitness_challenges, :badge_name if column_exists?(:fitness_challenges, :badge_name)
    remove_column :fitness_challenges, :badge_id if column_exists?(:fitness_challenges, :badge_id)
  end
end
