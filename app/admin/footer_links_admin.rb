Trestle.resource(:footer_links) do
  menu do
    group :site do
      item :footer_links, icon: "fa fa-link"
    end
  end

  table do
    column :footer_section
    column :label
    column :url
    column :published
    column :position
    actions
  end

  form do |fl|
    select :footer_section_id, FooterSection.order(:position).map { |s| [s.title, s.id] }
    text_field :label
    text_field :url
    number_field :position
    check_box :published
    check_box :target_blank, label: "Открывать в новой вкладке"
  end
end
