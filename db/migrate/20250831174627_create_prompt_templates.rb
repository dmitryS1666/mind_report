class CreatePromptTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :prompt_templates do |t|
      t.string :key
      t.text :system_prompt
      t.text :user_prompt
      t.integer :version

      t.timestamps
    end
  end
end
