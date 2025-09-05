Trestle.resource(:footer_sections) do
  menu do
    group :site do
      item :footer_sections, icon: "fa fa-columns"
    end
  end

  table do
    column :title
    column :published
    column :position
    actions
  end

  form do |fs|
    text_field :title
    number_field :position
    check_box :published
  end
end
