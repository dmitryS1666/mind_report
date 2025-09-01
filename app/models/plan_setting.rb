class PlanSetting < ApplicationRecord
  enum plan: { free: 0, pro: 1 }

  validates :plan, presence: true, uniqueness: true
  validates :limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
