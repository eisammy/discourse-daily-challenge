# frozen_string_literal: true

class AddFinalPostSentToFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:fitness_challenges, :final_post_sent)
      add_column :fitness_challenges, :final_post_sent, :boolean, default: false, null: false
    end
  end

  def down
    remove_column :fitness_challenges, :final_post_sent if column_exists?(:fitness_challenges, :final_post_sent)
  end
end
