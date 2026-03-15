class Booking < ApplicationRecord
  enum status: { confirmed: 0, cancelled: 1, no_show: 2 }

  belongs_to :resource
  belongs_to :user

  validates :booking_date, :start_slot, :end_slot, presence: true
  # slot 0 = 00:00–00:30
  # slot 47 = 23:30–24:00
  # end_slot is exclusive
  validates :start_slot, numericality: { in: 0..47 }
  validates :end_slot,   numericality: { in: 1..48 }
  validate  :end_after_start
  validate  :within_operating_hours
  validate  :duration_within_limits
  validate  :not_in_past
  validate  :no_overlap, on: :create

  scope :active, -> { where(status: :confirmed) }
  scope :on_date, ->(date) { where(booking_date: date) }

  before_validation :auto_confirm, on: :create

  def duration_slots  = end_slot - start_slot
  def duration_minutes = duration_slots * 30

  def time_range_display
    r = resource
    "#{r.slot_to_time(start_slot)}–#{r.slot_to_time(end_slot)}"
  end

  # cancelled bookings are not considered
  # def cancel!
  #   update!(status: :cancelled)
  # end

  private

  def end_after_start
    return unless start_slot && end_slot

    if end_slot <= start_slot
      # This should never happen if the frontend is working correctly, but we validate it just in case.
      # Possible reasons:
      # 1. Bug
      # 2. Malicious user trying to bypass frontend validation (e.g. via API or direct DB manipulation)
      # 3. API misuse (e.g. admin accidentally entering wrong values in the console
      errors.add(:base, "Invalid booking request")
      # log the details for investigation, but don't expose the internal logic to the user
      Rails.logger.error "[SECURITY] Invalid booking attempt by user #{user_id}: slots #{start_slot}-#{end_slot}"
    end
  end

  def within_operating_hours
    return unless resource && start_slot && end_slot
    if start_slot < resource.effective_op_start || end_slot > resource.effective_op_end
      errors.add(:base, "Must be within #{resource.operating_hours_display}")
    end
  end

  def duration_within_limits
    return unless resource && start_slot && end_slot
    max = resource.effective_max_slots
    min = resource.effective_min_slots
    slots = duration_slots
    errors.add(:base, "Maximum #{max * 30} minutes") if slots > max
    errors.add(:base, "Minimum #{min * 30} minutes") if slots < min
  end

  def not_in_past
    return unless booking_date
    errors.add(:booking_date, "cannot be in the past") if booking_date < Date.current
  end

  def no_overlap
    return unless resource_id && booking_date && start_slot && end_slot

    # 只檢查 confirmed 的 booking（pending 只是臨時，不算衝突）
    overlap = Booking.where(resource_id:, booking_date:)
                     .where(status: :confirmed)
                     .where("start_slot < ? AND end_slot > ?", end_slot, start_slot)
    errors.add(:base, "Time slot conflicts with existing booking") if overlap.exists?
  end

  # 新增：job 成功後轉 confirmed
  def confirm!
    update!(status: :confirmed)
  end

  # 新增：更新 Redis bitmap（成功 insert 後 call）
  def update_occupied_bitmap
    ResourceAvailabilityService.update_occupied_bitmap(resource_id, booking_date, (start_slot...end_slot).to_a)
  end

  # 新增：清除 pending bitmap（job 完成或失敗時 call）
  def clear_pending_bitmap
    ResourceAvailabilityService.clear_pending_bitmap(resource_id, booking_date, (start_slot...end_slot).to_a)
  end
end
