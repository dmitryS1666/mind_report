Trestle.resource(:prompt_templates) do
  menu do
    item "Промты", icon: "fa fa-file-alt"
  end

  # Поиск по ключу/текстам
  search do |query|
    if query.present?
      PromptTemplate.where("key ILIKE :q OR system_prompt ILIKE :q OR user_prompt ILIKE :q", q: "%#{query}%")
    else
      PromptTemplate.all
    end
  end

  scopes do
    scope :active, -> { PromptTemplate.where(active: true) }, default: true
    scope :inactive, -> { PromptTemplate.where(active: false) }
    scope :all, -> { PromptTemplate.all }
  end

  table do
    column :id
    column :key, link: true
    column :version
    column :plan,         ->(p) { status_tag p.plan, p.plan == "pro" ? :success : :default }
    column :report_kind,  ->(p) { status_tag p.report_kind }
    column :locale
    column :active, align: :center
    column :updated_at, align: :center
    actions
  end

  form do |p|
    tab :general do
      text_field :key
      number_field :version
      select :plan, PromptTemplate.plans.keys
      select :report_kind, PromptTemplate.report_kinds.keys
      text_field :locale
      check_box :active
    end

    tab :prompts do
      text_area :system_prompt, rows: 10, class: "font-mono"
      text_area :user_prompt,   rows: 16, class: "font-mono"
      text_area :notes,         rows: 4
    end

    tab :meta do
      # если нет json-редактора — используем многострочный ввод
      text_area :metadata, rows: 8, class: "font-mono",
        help: "JSON (например: {\"origin\":\"seed\",\"kind\":\"demo_short\"})"
    end
  end

  # Разрешаем все нужные атрибуты
  params do |params|
    params.require(:prompt_template).permit(
      :key, :version, :plan, :report_kind, :locale,
      :system_prompt, :user_prompt, :notes, :active, :metadata
    )
  end

  # Доп. действие: клонировать версию
  controller do
    def clone
      src = admin.find_instance(params)
      dst = src.dup
      dst.version = (PromptTemplate.where(key: src.key).maximum(:version) || 0) + 1
      dst.active = false
      dst.save!
      flash[:notice] = "Версия склонирована как v#{dst.version} (неактивна)"
      redirect_to admin.path(:edit, id: dst)
    end
  end

  routes do
    post :clone, on: :member
  end
end
