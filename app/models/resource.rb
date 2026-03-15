class Resource < ApplicationRecord
  CLASS_DEFAULTS = {
    max_slots_per_booking: 4,
    min_slots_per_booking: 1,
    advance_booking_days:  14,
    operating_start_slot:  16,
    operating_end_slot:    44
  }.freeze

  belongs_to :department
  has_many :bookings, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { where(is_active: true) }

  def effective(attr)
    read_attribute(attr) || self.class::CLASS_DEFAULTS[attr] || Resource::CLASS_DEFAULTS[attr]
  end

  def effective_max_slots    = effective(:max_slots_per_booking)
  def effective_min_slots    = effective(:min_slots_per_booking)
  def effective_advance_days = effective(:advance_booking_days)
  def effective_op_start     = effective(:operating_start_slot)
  def effective_op_end       = effective(:operating_end_slot)

  def slot_to_time(slot)
    format("%02d:%02d", slot / 2, (slot % 2) * 30)
  end

  def operating_hours_display
    "#{slot_to_time(effective_op_start)}–#{slot_to_time(effective_op_end)}"
  end
end
