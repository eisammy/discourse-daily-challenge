# frozen_string_literal: true

class RenameFitnessTablesToDaily < ActiveRecord::Migration[7.0]
  def up
    rename_table :fitness_challenges, :daily_challenges if table_exists?(:fitness_challenges)
    rename_table :fitness_check_ins, :daily_check_ins if table_exists?(:fitness_check_ins)
  end

  def down
    rename_table :daily_challenges, :fitness_challenges if table_exists?(:daily_challenges)
    rename_table :daily_check_ins, :fitness_check_ins if table_exists?(:daily_check_ins)
  end
end
