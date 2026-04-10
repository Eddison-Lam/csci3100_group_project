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

  def validate_slot_range(start_slot, end_slot)
    errors = []
    # range check
    if start_slot.nil? || end_slot.nil?
      errors << "Slots cannot be blank"
      return errors
    end
    errors << "Invalid slot range" if start_slot >= end_slot
    errors << "Start slot out of range (0-47)" unless (0..47).cover?(start_slot)
    errors << "End slot out of range (1-48)" unless (1..48).cover?(end_slot)
    # open hour check
    unless within_operating_hours?(start_slot, end_slot)
      errors << "Must be within #{operating_hours_display}"
    end
    # duration check
    slot_count = end_slot - start_slot
    min = effective_min_slots
    max = effective_max_slots
    errors << "Minimum #{min * 30} minutes (#{min} slots) required" if slot_count < min
    errors << "Maximum #{max * 30} minutes (#{max} slots) allowed" if slot_count > max
    # pass validate check
    errors
  end

  # quick check if selected slots can book or not
  def can_book_slots?(start_slot, end_slot)
    validate_slot_range(start_slot, end_slot).empty?
  end

  # Check if the dates are within the allowed booking range.
  def can_book_date?(date)
    return false if date.nil?
    date >= Date.current && date <= max_booking_date
  end

  # Maximum bookable dates
  def max_booking_date
    Date.current + effective_advance_days.days
  end

  # Check if it is within opening hours
  def within_operating_hours?(start_slot, end_slot)
    start_slot >= effective_op_start && end_slot <= effective_op_end
  end
end
