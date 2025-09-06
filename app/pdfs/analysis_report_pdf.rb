# frozen_string_literal: true
require "prawn"

class AnalysisReportPdf
  FONT_DIRS = [
    Rails.root.join("app", "assets", "fonts"),
    Rails.root.join("vendor", "fonts"),
    Rails.root.join("app", "pdfs", "fonts")
  ].freeze

  FONTS = {
    text: {
      name:  "DejaVuSans",
      files: {
        normal: "DejaVuSans.ttf",
        bold:   "DejaVuSans-Bold.ttf",
        italic: "DejaVuSans-Oblique.ttf",
        bold_italic: "DejaVuSans-BoldOblique.ttf"
      }
    },
    emoji: {
      name: "NotoEmoji",
      files: { normal: "NotoEmoji-Regular.ttf" } # монохромные emoji-глифы
    }
  }.freeze

  def initialize(analysis)
    @analysis = analysis
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 36) do |pdf|
      register_fonts!(pdf)

      pdf.text "Анализ ##{@analysis.id}", size: 18, style: :bold
      pdf.move_down 6
      pdf.fill_color "555555"
      pdf.text "Статус: #{safe(@analysis.status.to_s.titleize)}", size: 10
      pdf.text "Дата: #{safe(@analysis.created_at.strftime("%d.%m.%Y %H:%M"))}", size: 10
      pdf.fill_color "000000"
      pdf.move_down 12

      if @analysis.report_text.present?
        pdf.text "Отчёт", size: 14, style: :bold
        pdf.move_down 4
        pdf.text safe(@analysis.report_text), size: 10, leading: 2
        pdf.move_down 12
      end

      if @analysis.transcript.present?
        pdf.text "Транскрипт", size: 12, style: :bold
        pdf.move_down 4
        pdf.text safe(@analysis.transcript), size: 9, leading: 2
      end
    end.render
  end

  private

  def safe(str)
    str.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "�")
  end

  def register_fonts!(pdf)
    # регистрируем основной текстовый шрифт
    if files = resolve_font_files(FONTS[:text][:files])
      pdf.font_families.update(FONTS[:text][:name] => files)
      pdf.font(FONTS[:text][:name])
    else
      raise "Не найдены TTF-файлы DejaVuSans*.ttf в #{FONT_DIRS.join(", ")}"
    end

    # регистрируем emoji-fallback (по возможности)
    if (emoji_file = find_font_file(FONTS[:emoji][:files][:normal]))
      pdf.font_families.update(FONTS[:emoji][:name] => { normal: emoji_file })
      pdf.fallback_fonts [FONTS[:emoji][:name]] if pdf.respond_to?(:fallback_fonts)
    end
  end

  def resolve_font_files(map)
    out = {}
    map.each { |style, filename| if path = find_font_file(filename); out[style] = path end }
    return nil unless out[:normal]
    out[:bold]        ||= out[:normal]
    out[:italic]      ||= out[:normal]
    out[:bold_italic] ||= out[:bold]
    out
  end

  def find_font_file(filename)
    FONT_DIRS.each do |dir|
      path = dir.join(filename)
      return path.to_s if File.exist?(path)
    end
    nil
  end
end
