class CreateAnalyses < ActiveRecord::Migration[7.0]
  def change
    create_table :analyses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.text :transcript
      t.integer :report_kind
      t.string :openai_model
      t.jsonb :report_json
      t.text :report_text
      t.string :prompt_key
      t.text :error_message

      t.timestamps
    end
  end
end
