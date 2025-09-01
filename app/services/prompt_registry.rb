class PromptRegistry
  CACHE_TTL = 10.minutes

  # plan: :free / :pro (или user.plan, если у тебя enum в User)
  # report_kind: :short / :full
  def self.get(key:, plan:, report_kind:, locale: I18n.locale)
    cache_key = ["prompt", key, plan, report_kind, locale].join(":")

    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      tmpl = PromptTemplate.fetch(key: key, plan: plan, report_kind: report_kind, locale: locale)
      raise "PromptTemplate not found: #{cache_key}" unless tmpl
      { system: tmpl.system_prompt, user: tmpl.user_prompt, meta: tmpl.metadata, version: tmpl.version }
    end
  end
end
