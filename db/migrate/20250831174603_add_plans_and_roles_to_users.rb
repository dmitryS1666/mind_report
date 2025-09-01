class AddPlansAndRolesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :integer
    add_column :users, :plan, :integer
    add_column :users, :plan_renews_at, :datetime
    add_column :users, :analyses_used, :integer
  end
end
