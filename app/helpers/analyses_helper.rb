module AnalysesHelper
  def status_label(analysis)
    case analysis.status.to_sym
    when :queued      then "Готовлюсь к анализу…"
    when :processing  then "Обрабатываю…"
    when :ready       then "Готово"
    when :failed      then "Ошибка"
    else analysis.status
    end
  end

  def status_badge_classes(analysis)
    base = "inline-flex items-center rounded-full px-2 py-1 text-xs font-medium"
    case analysis.status.to_sym
    when :queued      then "#{base} bg-slate-100 text-slate-700 border border-slate-200"
    when :processing  then "#{base} bg-amber-50 text-amber-900 border border-amber-200"
    when :ready       then "#{base} bg-emerald-50 text-emerald-900 border border-emerald-200"
    when :failed      then "#{base} bg-rose-50 text-rose-900 border border-rose-200"
    else                   "#{base} bg-slate-100 text-slate-700 border border-slate-200"
    end
  end
end
