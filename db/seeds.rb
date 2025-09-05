PromptTemplate.find_or_create_by!(
  key: "sales_session",
  version: 1,
  plan: :free,
  report_kind: :short,
  locale: "ru"
) do |p|
  p.system_prompt = <<~SYS
    Ты — ассистент-аналитик продаж. Делаешь краткий, понятный отчёт без глубокой психологии.
  SYS
  p.user_prompt = <<~USR
    Дано: транскрипт разговора менеджера с клиентом.
    Задача: коротко ответить по 4 пунктам:
    1) Клиент: цель, основная боль, общий тип (эмоциональный/рациональный/сомневающийся).
    2) Менеджер: как вёл диалог (уверенность, контакт, аргументы, упоминание цены/предоплаты).
    3) Итог: была ли продажа/прогресс?
    4) Рекомендация: 1–2 совета для улучшения.
    Формат: маркированные пункты, до 120–160 слов, без лишних разделов.
  USR
  p.notes = "Демо/урезанный отчёт"
  p.metadata = { origin: "seed", kind: "demo_short" }
end

PromptTemplate.find_or_create_by!(
  key: "sales_session",
  version: 1,
  plan: :pro,
  report_kind: :full,
  locale: "ru"
) do |p|
  p.system_prompt = <<~SYS
    Ты — эксперт по анализу продаж и психологии (Олпорт, Бек и пр.). Делаешь глубокий многошаговый анализ.
  SYS
  p.user_prompt = File.read(Rails.root.join("config", "prompts", "sales_session_full_ru_v1.txt")) rescue <<~USR
    <!-- сюда можно положить полный промт из документа -->
    [ПОЛНЫЙ ПРОМТ...]
  USR
  p.notes = "Полный отчёт для платного плана"
  p.metadata = { origin: "seed", kind: "full_v1" }
end

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.plan = :pro
end

SiteSetting.find_or_create_by!(key: "footer_text") do |s|
  s.value = "MindReport — инструмент для транскрибации и анализа аудио/текста. Этот текст можно изменить в админке."
end

main = FooterSection.find_or_create_by!(title: "Разделы") do |s|
  s.position  = 0
  s.published = true
end
FooterLink.find_or_create_by!(footer_section: main, label: "Главная", url: "/") do |l|
  l.position = 0
end
FooterLink.find_or_create_by!(footer_section: main, label: "Отчёты", url: "/analyses") do |l|
  l.position = 1
end

help = FooterSection.find_or_create_by!(title: "Поддержка") do |s|
  s.position  = 1
  s.published = true
end
FooterLink.find_or_create_by!(footer_section: help, label: "Помощь", url: "#") { |l| l.position = 0 }
FooterLink.find_or_create_by!(footer_section: help, label: "Контакты", url: "mailto:support@example.com") { |l| l.position = 1 }
