class Equipment < Resource
  CLASS_DEFAULTS = Resource::CLASS_DEFAULTS.merge(
    max_slots_per_booking: 96,
    advance_booking_days:  7
  ).freeze

  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true

  scope :by_department, ->(dept_id) {
    return all if dept_id.blank?
    where(department_id: dept_id)
  }

  scope :filtered, ->(params) {
    active
      .by_department(params[:department_id])
      .order(:name)
  }

  def available_quantity_on(date)
    total_booked = bookings
                    .where(booking_date: date)
                    .where(status: [ :confirmed, :pending_payment ])
                    .count

    quantity - total_booked
  end

  def available_for_booking_on?(date)
    available_quantity_on(date) > 0
  end
end
