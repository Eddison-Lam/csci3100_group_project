class Admin::DailySummariesController < Admin::BaseController
  def index
    @selected_date = parse_selected_date(params[:date])

    base_room_query = Booking.joins(:resource).where(booking_date: @selected_date, resources: { type: "Room" })
    base_equipment_query = Booking.joins(:resource).where(booking_date: @selected_date, resources: { type: "Equipment" })

    unless current_user.superadmin?
      base_room_query = base_room_query.where(resources: { department_id: current_user.department_id })
      base_equipment_query = base_equipment_query.where(resources: { department_id: current_user.department_id })
    end

    @room_bookings = base_room_query
    @equipment_bookings = base_equipment_query

    @room_summaries = build_summary(@room_bookings, label_for: ->(resource) { resource.building.presence || "Unknown" })
    @equipment_summaries = build_summary(@equipment_bookings, label_for: ->(resource) { resource.name })

    @room_totals = build_totals(@room_bookings)
    @equipment_totals = build_totals(@equipment_bookings)
  end

  def build_summary(bookings, label_for:)
    bookings.includes(:resource).group_by { |booking| label_for.call(booking.resource) }.map do |label, grouped_bookings|
      {
        label: label,
        total_bookings: grouped_bookings.size,
        confirmed_count: grouped_bookings.count(&:confirmed?),
        cancelled_count: grouped_bookings.count(&:cancelled?),
        no_show_count: grouped_bookings.count(&:no_show?),
        pending_payment_count: grouped_bookings.count(&:pending_payment?),
        distinct_resources_count: grouped_bookings.map(&:resource_id).uniq.size
      }
    end.sort_by { |summary| summary[:label].to_s }
  end

  def build_totals(bookings)
    {
      total_bookings: bookings.count,
      confirmed_total: bookings.count(&:confirmed?),
      cancelled_total: bookings.count(&:cancelled?),
      no_show_total: bookings.count(&:no_show?),
      pending_payment_total: bookings.count(&:pending_payment?)
    }
  end

  private

  def parse_selected_date(date_param)
    return Date.current unless date_param.present?

    Date.parse(date_param)
  rescue ArgumentError
    Date.current
  end
end
