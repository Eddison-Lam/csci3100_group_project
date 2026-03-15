class Room < Resource
  CLASS_DEFAULTS = Resource::CLASS_DEFAULTS.merge(
    max_slots_per_booking: 8,
    advance_booking_days:  30
  ).freeze

  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true
  validates :location, presence: true
  validates :building, presence: true

  # ── Filter Scopes ──
  scope :by_buildings, ->(buildings) {
    return all if buildings.blank? || buildings.reject(&:blank?).empty?
    where(building: buildings)
  }

  scope :by_room_types, ->(types) {
    return all if types.blank? || types.reject(&:blank?).empty?
    where(room_type: types)
  }

  scope :by_min_capacity, ->(cap) {
    return all if cap.blank? || cap.to_i <= 0
    where("capacity >= ?", cap.to_i)
  }

  scope :by_department, ->(dept_id) {
    return all if dept_id.blank?
    where(department_id: dept_id)
  }

  scope :filtered, ->(params) {
    active
      .by_department(params[:department_id])
      .by_buildings(params[:buildings])
      .by_room_types(params[:room_types])
      .by_min_capacity(params[:capacity])
      .order(:building, :name)
  }

  # ── Dropdown Options ──

  # All available buildings
  def self.available_buildings
    active
      .where.not(building: [ nil, "" ])
      .distinct
      .order(:building)
      .pluck(:building)
  end

  # Select buildings filter room_types
  def self.available_room_types(buildings: nil)
    scope = active.where.not(room_type: [ nil, "" ])

    if buildings.present? && buildings.reject(&:blank?).any?
      scope = scope.where(building: buildings)
    end

    scope.distinct.order(:room_type).pluck(:room_type)
  end

  def full_location
    "#{building} #{location}"
  end
end
