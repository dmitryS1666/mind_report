# Промпты
PromptTemplate.find_or_create_by!(key: 'short_report') do |p|
  p.version = 1
  p.system_prompt = "Ты — аналитик. Кратко выделяй ключевые тезисы и выводы."
  p.user_prompt = <<~PROMPT
    Транскрипт:
    {{TRANSCRIPT}}

    Сформируй краткий отчёт:
    - Основные темы (3–5 маркеров)
    - Ключевые цитаты (до 3)
    - Два практических совета
  PROMPT
end

PromptTemplate.find_or_create_by!(key: 'full_report') do |p|
  p.version = 1
  p.system_prompt = "Ты — старший аналитик. Дай структурный глубинный анализ."
  p.user_prompt = <<~PROMPT
    Транскрипт:
    {{TRANSCRIPT}}

    Сформируй подробный отчёт:
    1) Резюме (5–7 предложений)
    2) Темы/подтемы (иерархия)
    3) Цитаты с тайм-кодами (если есть)
    4) Риски/возможности
    5) План действий на 7 дней
  PROMPT
end

# Тарифы/квоты (можно править в админке)
PlanSetting.find_or_create_by!(plan: :free) { |ps| ps.limit = 3;  ps.price_cents = 0 }
PlanSetting.find_or_create_by!(plan: :pro)  { |ps| ps.limit = 10; ps.price_cents = 990_00 }

puts "Seeds ok: prompts=#{PromptTemplate.count}, plans=#{PlanSetting.count}"
