class AddFieldsToPromptTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :prompt_templates, :plan, :integer
    add_column :prompt_templates, :report_kind, :integer
    add_column :prompt_templates, :locale, :string
    add_column :prompt_templates, :notes, :text
    add_column :prompt_templates, :active, :boolean
    add_column :prompt_templates, :metadata, :jsonb
  end
end
