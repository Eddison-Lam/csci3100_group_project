class Equipment < Resource
  CLASS_DEFAULTS = Resource::CLASS_DEFAULTS.merge(
    max_slots_per_booking: 96,
    advance_booking_days:  7
  ).freeze

  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true
end
