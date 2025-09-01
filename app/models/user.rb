class User < ApplicationRecord
  # Devise модули (минимальный набор)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
       
  # Нормализуем e-mail (и защитим уникальность кейс-инсенситив)
  before_validation :downcase_email
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def downcase_email
    self.email = email.to_s.strip.downcase
  end

  enum role: { user: 0, admin: 1 }, _prefix: true
  enum plan: { free: 0, pro: 1 }, _prefix: true

  has_many :analyses, dependent: :destroy
  has_many :sessions, dependent: :destroy

  # ===== Квоты и тарифы =====
  def quota_limit
    PlanSetting.find_by(plan: plan)&.limit || default_quota
  end

  def default_quota
    pro? ? 10 : 3
  end

  def can_request_full_report?
    pro?
  end

  def in_quota?
    period_reset_if_needed!
    analyses_used < quota_limit
  end

  def consume_quota!
    update!(analyses_used: analyses_used + 1)
  end

  def period_reset_if_needed!
    if plan_renews_at.blank? || Time.current >= plan_renews_at
      update!(plan_renews_at: 30.days.from_now, analyses_used: 0)
    end
  end
end
