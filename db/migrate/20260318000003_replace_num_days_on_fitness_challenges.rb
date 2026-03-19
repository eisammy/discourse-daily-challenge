# frozen_string_literal: true

class ReplaceNumDaysOnFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:fitness_challenges, :end_date)
      add_column :fitness_challenges, :end_date, :date

      if column_exists?(:fitness_challenges, :num_days)
        execute <<~SQL
          UPDATE fitness_challenges
          SET end_date = start_date + (num_days * INTERVAL '1 day')
        SQL
      end

      change_column_null :fitness_challenges, :end_date, false
    end

    unless column_exists?(:fitness_challenges, :check_ins_needed)
      add_column :fitness_challenges, :check_ins_needed, :integer, default: 20, null: false
    end
  end

  def down
    add_column :fitness_challenges, :num_days, :integer unless column_exists?(:fitness_challenges, :num_days)

    execute <<~SQL
      UPDATE fitness_challenges
      SET num_days = end_date - start_date
    SQL

    change_column_null :fitness_challenges, :num_days, false

    remove_column :fitness_challenges, :end_date if column_exists?(:fitness_challenges, :end_date)
    remove_column :fitness_challenges, :check_ins_needed if column_exists?(:fitness_challenges, :check_ins_needed)
  end
end
