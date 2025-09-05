Trestle.resource(:site_settings) do
  menu do
    group :site do
      item :settings, icon: "fa fa-sliders"
    end
  end

  table do
    column :key
    column :updated_at
    actions
  end

  form do |s|
    text_field :key, disabled: s.persisted?
    text_area  :value, rows: 8
    sidebar do
      text "Используется для: базовый текст футера (key: footer_text) и др."
    end
  end
end
