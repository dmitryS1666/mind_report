class PromptTemplate < ApplicationRecord
  enum plan:        { free: 0, pro: 1 }
  enum report_kind: { short: 0, full: 1 }

  scope :active, -> { where(active: true) }

  validates :key, :version, :plan, :report_kind, :locale, :system_prompt, :user_prompt, presence: true

  # Возвращает «лучшее совпадение» (активный промт с максимальной версией)
  def self.fetch(key:, plan:, report_kind:, locale: I18n.locale)
    plan = plan.to_s
    report_kind = report_kind.to_s

    rel = active.where(key: key, plan: plans[plan], report_kind: report_kinds[report_kind], locale: locale.to_s)
    rel = rel.order(version: :desc)

    # 1) точное совпадение локали
    tmpl = rel.first
    return tmpl if tmpl

    # 2) fallback на :ru / :en
    %w[ru en].each do |fallback|
      tmpl = active.where(key: key, plan: plans[plan], report_kind: report_kinds[report_kind], locale: fallback).order(version: :desc).first
      return tmpl if tmpl
    end

    nil
  end
end
