Trestle.resource(:users) do
  menu do
    item "Пользователи", icon: "fa fa-users"
  end

  # Поиск по email
  search do |query|
    if query.present?
      User.where("email ILIKE ?", "%#{query}%")
    else
      User.all
    end
  end

  table do
    column :id
    column :email, link: true
    column :role, ->(u) { u.role ? status_tag(u.role, :default) : "-" }
    column :plan, ->(u) { u.plan ? status_tag(u.plan, u.plan == "pro" ? :success : :default) : "-" }
    column :analyses_used
    column :plan_renews_at
    column :confirmed_at
    column :created_at
    actions
  end

  form do |u|
    tab :main do
      text_field :email
      select :role, User.roles.keys, include_blank: true if User.respond_to?(:roles)
      select :plan, User.plans.keys, include_blank: true if User.respond_to?(:plans)
      number_field :analyses_used
      datetime_field :plan_renews_at
      datetime_field :confirmed_at
    end

    tab :security do
      password_field :password, help: "Оставьте пустым, если не меняете"
      password_field :password_confirmation
    end
  end

  params do |params|
    # убрать пустой пароль, чтобы не сбрасывать случайно
    if params[:user].present? && params[:user][:password].blank?
      params[:user].extract!(:password, :password_confirmation)
    end

    params.require(:user).permit(
      :email, :role, :plan, :analyses_used, :plan_renews_at, :confirmed_at,
      :password, :password_confirmation
    )
  end
end
