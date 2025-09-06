# 🧠 MindReport

MindReport — MVP веб-приложение на **Ruby on Rails**, которое позволяет пользователям загружать аудиофайлы, анализировать их и получать отчёты на основе заготовленных промтов для OpenAI GPT-5.  
Приложение построено в стиле ChatGPT: чат-интерфейс, прогресс загрузки, «мигающий» текст при обработке, два типа отчётов — **демо (короткий)** и **полный**.

---

## Быстрый старт (локально)

```bash
# 1) Установите зависимости
bundle install
bin/rails db:setup

# 2) Скопируйте переменные окружения
cp .env.example .env

# 3) Укажите OPENAI_API_KEY (или включите фейк: OPENAI_FAKE=1)
#    По умолчанию:
#      OPENAI_MODEL=gpt-5
#      OPENAI_TRANSCRIPTION_MODEL=whisper-1

# 4) Запуск
bin/dev
# или
rails s
```

---

## Переменные окружения

| Переменная | Назначение |
|---|---|
| `OPENAI_API_KEY` | Ключ OpenAI (обязательно в проде) |
| `OPENAI_MODEL` | Модель для генерации отчётов (Responses API), по умолчанию `gpt-5` |
| `OPENAI_TRANSCRIPTION_MODEL` | Модель транскрибации (Whisper), по умолчанию `whisper-1` |
| `OPENAI_API_BASE` | Базовый URL, если используете прокси/шлюз (совместимый с OpenAI API) |
| `OPENAI_ORG_ID` / `OPENAI_PROJECT_ID` | Опционально, если используется |
| `OPENAI_TIMEOUT` | Таймаут запросов к OpenAI в секундах (по умолчанию 30) |
| `OPENAI_FAKE` | `1` — включить фейковый клиент для разработки без сети |
| `HTTPS_PROXY` / `HTTP_PROXY` | Системные прокси-переменные (поддерживаются инициалайзером) |

### Пример `.env.example`
```dotenv
# == OpenAI ==
OPENAI_API_KEY=
OPENAI_MODEL=gpt-5
OPENAI_TRANSCRIPTION_MODEL=whisper-1
OPENAI_API_BASE=
OPENAI_ORG_ID=
OPENAI_PROJECT_ID=
OPENAI_TIMEOUT=30
OPENAI_FAKE=
# HTTPS_PROXY=https://user:pass@proxy-host:port
# HTTP_PROXY=http://user:pass@proxy-host:port
```

---

## Подключение к OpenAI через ENV + прокси

**Инициалайзер:** `config/initializers/openai.rb`  
Поддерживаются:
- `OPENAI_API_KEY` — ключ.
- `OPENAI_API_BASE` — базовый URL (совместимый шлюз/прокси; для Azure — ваш endpoint).
- `OPENAI_ORG_ID`, `OPENAI_PROJECT_ID` — при необходимости.
- `OPENAI_TIMEOUT` — таймаут запросов.
- `HTTPS_PROXY`/`HTTP_PROXY`/`OPENAI_PROXY` — http(s)-прокси.
- `OPENAI_FAKE=1` — локальная заглушка без сети.

В `app/services/audio_transcriber.rb` модель Whisper берётся из `ENV.fetch("OPENAI_TRANSCRIPTION_MODEL", "whisper-1")`.  
В контроллере `AnalysesController` дефолт модели ответов — `ENV.fetch('OPENAI_MODEL', 'gpt-5')`.

---

## Прокси в проде: варианты

1. **Сетевой HTTP(S)-прокси** — выставить `HTTPS_PROXY`/`HTTP_PROXY`.  
2. **Шлюз для OpenAI совместимый по API** — указать `OPENAI_API_BASE` (например, `https://proxy.example.com/v1`).

> Для Azure OpenAI используйте свой endpoint в `OPENAI_API_BASE` и соответствующую модель в `OPENAI_MODEL`.

---

## Единые статусы анализа

Определены в `app/models/analysis.rb` и отрисовываются унифицировано через хелперы/partial:

- `queued` → «Готовлюсь к анализу…»  
- `processing` → «Обрабатываю…»  
- `ready` → «Готово»  
- `failed` → «Ошибка»  

Использование статуса в списке истории (`app/views/dashboard/_history_list.html.erb`) и на карточках (`analyses/_status`).

---

## Анимация «побуквенного» вывода

Stimulus-контроллер `app/javascript/controllers/typewriter_controller.js` выводит отчёт по символу (с учётом `prefers-reduced-motion`).  
Подключено в:
- `app/views/analyses/show.html.erb`
- `app/views/analyses/_panel.html.erb`

Настройка скорости: `data-typewriter-speed-value` (мс/символ).

---

## Экспорт в PDF

Кнопка «Скачать PDF» в `show` генерирует документ через Prawn:

- Гем: `prawn` (добавлен в `Gemfile`).  
- Рендерер: `app/pdfs/analysis_report_pdf.rb`.  
- Роут: `GET /analyses/:id/download_pdf` (см. `config/routes.rb`).  
- Экшен: `AnalysesController#download_pdf`.

```ruby
send_data AnalysisReportPdf.new(@analysis).render,
          filename: "analysis-#{@analysis.id}.pdf",
          type: "application/pdf",
          disposition: "attachment"
```

---

## Footer

`app/views/shared/_footer.html.erb` — адаптивная сетка, ссылки из `FooterSection/FooterLink`, текст настраивается через `SiteSetting`.  
Удалены артефакты классов, исправлена адаптивная раскладка.

---

## Изменённые/добавленные файлы

- `.env.example` — пример конфигурации.  
- `config/initializers/openai.rb` — все настройки OpenAI через ENV + прокси.  
- `app/services/audio_transcriber.rb` — модель Whisper из ENV.  
- `app/controllers/analyses_controller.rb` — дефолт модели из ENV, добавлен `download_pdf`.  
- `config/routes.rb` — маршрут `download_pdf`.  
- `app/javascript/controllers/typewriter_controller.js` — анимация печати.  
- `app/javascript/controllers/analysis_status_controller.js` — фикс стабильного поведения.  
- `app/views/dashboard/_history_list.html.erb` — статус через общий partial.  
- `app/views/analyses/show.html.erb`, `app/views/analyses/_panel.html.erb` — подключение анимации и кнопки PDF.  
- `app/pdfs/analysis_report_pdf.rb` — генерация PDF.  
- `app/views/shared/_footer.html.erb` — обновлённый футер.  
- `Gemfile` — добавлен `prawn`.

---

## Примечания

- Для «глянцевого» серверного PDF можно заменить на `wicked_pdf`/`wkhtmltopdf` (потребуется бинарник wkhtmltopdf).  
- Для dev без сети/ключа — `OPENAI_FAKE=1`.  
- Эффект печати — клиентский (без стриминга от OpenAI), но UX максимально близок к чату.

---

## История изменений (коротко)

- README полностью переписан.  
- Подключение OpenAI → ENV (+ proxy/timeout/org/project).  
- Единые статусы и их отображение.  
- Исправлен и обновлён footer.  
- Подготовлен proxy-слой (ENV + base URL + системные прокси).  
- Typewriter-анимация.  
- Экспорт PDF (Prawn).