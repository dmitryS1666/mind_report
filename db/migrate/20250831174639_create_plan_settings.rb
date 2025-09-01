class CreatePlanSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :plan_settings do |t|
      t.integer :plan
      t.integer :limit
      t.integer :price_cents

      t.timestamps
    end
  end
end
