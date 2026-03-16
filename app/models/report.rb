class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true

  STATUSES = %w[pending resolved dismissed].freeze
  REASONS  = %w[spam inappropriate fake harassment other].freeze

  validates :reason, inclusion: { in: REASONS }
  validates :status, inclusion: { in: STATUSES }

  scope :pending,   -> { where(status: "pending") }
  scope :resolved,  -> { where(status: "resolved") }
end
