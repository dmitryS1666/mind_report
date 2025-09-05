# db/migrate/20250905_create_site_settings_and_footer_entities.rb
class CreateSiteSettingsAndFooterEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :site_settings do |t|
      t.string :key, null: false
      t.text :value
      t.timestamps
    end
    add_index :site_settings, :key, unique: true

    create_table :footer_sections do |t|
      t.string  :title, null: false
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true
      t.timestamps
    end
    add_index :footer_sections, :position

    create_table :footer_links do |t|
      t.references :footer_section, null: false, foreign_key: true
      t.string  :label, null: false
      t.string  :url,   null: false
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true
      t.boolean :target_blank, null: false, default: false
      t.timestamps
    end
    add_index :footer_links, [:footer_section_id, :position]
  end
end
