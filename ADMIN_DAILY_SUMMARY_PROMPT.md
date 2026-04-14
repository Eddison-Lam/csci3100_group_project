# Add Admin Daily Summary Report

You are an expert Ruby on Rails developer. I am working on a CSCI3100 course project: a multi-tenant room/equipment booking system in Rails, with an admin portal and an `admin.html.erb` layout. I want you to add a new "Daily Summary" report for admins.

## Existing app structure

- Framework: Ruby on Rails.
- Booking model: `Booking`
  - Columns:
    - `booking_date` : `date` (the day of the booking)
    - `start_slot` : integer or string representing the starting time slot
    - `end_slot` : integer or string representing the ending time slot
    - `status` : string with these possible values:
      - `confirmed`
      - `cancelled`
      - `no_show`
      - `pending_payment`
- Location / building:
  - There is a `Resource` model with a string column `building`.
  - `Room` inherits from `Resource` and validates `building`.
  - There is **no** separate `Building` model; the building is just `resources.building`.
  - Bookings are associated to resources, so each booking can be traced to a building via its resource.
- Admin namespace:
  - `config/routes.rb` has `namespace :admin do ... end`.
  - Existing controllers:
    - `Admin::BaseController`
    - `Admin::RoomsController`
    - `Admin::EquipmentController`
    - `Admin::ResourcesController`
  - Admin layout file: `app/views/layouts/admin.html.erb`
    - `Admin::ResourcesController` explicitly uses `layout "admin"`.
    - The admin layout includes a sidebar with navigation items.
- Authorization:
  - The new report must be accessible only to authenticated admins, using the same filters as other `Admin::*` controllers.

## New feature: Admin Daily Summary report

Implement a new daily summary page in the admin portal with these pieces:

### 1. Routes

Add the following route inside the `namespace :admin` block in `config/routes.rb`:

```ruby
# config/routes.rb
namespace :admin do
  get "daily_summary", to: "daily_summaries#index", as: :daily_summary

  post "bookings/for_slot", to: "bookings#for_slot", as: :booking_for_slot
  resources :rooms, only: [:index, :show] do
    member do
      get :availability
    end
  end

  resources :equipment, only: [:index, :show] do
    member do
      get :availability
    end
  end

  resources :bookings, only: [:update, :destroy]
  resources :resources, only: [:index]
end
```

This creates `admin_daily_summary_path` and supports `GET /admin/daily_summary` with an optional `date` query string.

### 2. Controller

Create `app/controllers/admin/daily_summaries_controller.rb` with the following content:

```ruby
# app/controllers/admin/daily_summaries_controller.rb
class Admin::DailySummariesController < Admin::BaseController
  layout "admin"

  def index
    @selected_date = parse_selected_date(params[:date])

    bookings = Booking.includes(:resource).where(booking_date: @selected_date)
    bookings_by_building = bookings.group_by do |booking|
      booking.resource&.building.presence || "Unknown"
    end

    @building_summaries = bookings_by_building.map do |building, building_bookings|
      {
        building: building,
        total_bookings: building_bookings.size,
        confirmed_count: building_bookings.count(&:confirmed?),
        cancelled_count: building_bookings.count(&:cancelled?),
        no_show_count: building_bookings.count(&:no_show?),
        pending_payment_count: building_bookings.count(&:pending_payment?),
        distinct_resources_count: building_bookings.map(&:resource_id).uniq.size
      }
    end.sort_by { |summary| summary[:building].to_s }

    @totals = {
      total_bookings: bookings.size,
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
```

### 3. View

Create `app/views/admin/daily_summaries/index.html.erb` with the following content:

```erb
<!-- app/views/admin/daily_summaries/index.html.erb -->
<h1>Daily Booking Summary</h1>

<%= form_with url: admin_daily_summary_path, method: :get, local: true do |form| %>
  <div style="margin-bottom: 1rem;">
    <%= form.label :date, "Select date", style: "display: block; margin-bottom: 0.25rem;" %>
    <%= form.date_field :date, value: @selected_date.to_s, style: "padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px;" %>
  </div>

  <%= form.submit "Show summary", style: "padding: 0.5rem 1rem; background: #2c3e50; color: white; border: none; border-radius: 4px; cursor: pointer;" %>
<% end %>

<% if @building_summaries.any? %>
  <table style="width: 100%; border-collapse: collapse; margin-top: 1.5rem;">
    <thead>
      <tr style="background: #2c3e50; color: white; text-align: left;">
        <th style="padding: 0.75rem;">Building</th>
        <th style="padding: 0.75rem;">Total bookings</th>
        <th style="padding: 0.75rem;">Confirmed</th>
        <th style="padding: 0.75rem;">Cancelled</th>
        <th style="padding: 0.75rem;">No-show</th>
        <th style="padding: 0.75rem;">Pending payment</th>
        <th style="padding: 0.75rem;">Distinct resources booked</th>
      </tr>
    </thead>
    <tbody>
      <% @building_summaries.each do |summary| %>
        <tr style="border-bottom: 1px solid #e0e0e0;">
          <td style="padding: 0.75rem;"><%= summary[:building] %></td>
          <td style="padding: 0.75rem;"><%= summary[:total_bookings] %></td>
          <td style="padding: 0.75rem;"><%= summary[:confirmed_count] %></td>
          <td style="padding: 0.75rem;"><%= summary[:cancelled_count] %></td>
          <td style="padding: 0.75rem;"><%= summary[:no_show_count] %></td>
          <td style="padding: 0.75rem;"><%= summary[:pending_payment_count] %></td>
          <td style="padding: 0.75rem;"><%= summary[:distinct_resources_count] %></td>
        </tr>
      <% end %>
    </tbody>
    <tfoot>
      <tr style="background: #f4f6f6; font-weight: bold;">
        <td style="padding: 0.75rem;">Totals</td>
        <td style="padding: 0.75rem;"><%= @totals[:total_bookings] %></td>
        <td style="padding: 0.75rem;"><%= @totals[:confirmed_total] %></td>
        <td style="padding: 0.75rem;"><%= @totals[:cancelled_total] %></td>
        <td style="padding: 0.75rem;"><%= @totals[:no_show_total] %></td>
        <td style="padding: 0.75rem;"><%= @totals[:pending_payment_total] %></td>
        <td style="padding: 0.75rem;">&mdash;</td>
      </tr>
    </tfoot>
  </table>
<% else %>
  <p style="margin-top: 1.5rem; padding: 1rem; background: #fff3cd; border: 1px solid #ffeeba; color: #856404; border-radius: 4px;">
    No bookings found for this date.
  </p>
<% end %>
```

### 4. Update admin sidebar

Update the sidebar navigation in `app/views/layouts/admin.html.erb` to add the new Daily Summary link beneath the existing admin links. Use the same link style as the other sidebar items.

```erb
<!-- app/views/layouts/admin.html.erb -->
<nav>
  <%= link_to "Admin Home", root_path %>
  <%= link_to "View Rooms", admin_rooms_path %>
  <%= link_to "View Equipment", admin_equipment_index_path %>
  <%= link_to "Daily Summary", admin_daily_summary_path %>
  <hr style="border-color: #34495e; margin: 20px 0;">
  <%= button_to "Log Out", destroy_user_session_path, method: :delete, form: { data: { turbo: false } }, style: "background: #c0392b; color: white; border: none; padding: 8px 12px; cursor: pointer; border-radius: 4px; width: 100%;" %>
</nav>
```

## Notes

- The new `Admin::DailySummariesController` uses the same `Admin::BaseController` authorization filter.
- The page defaults to `Date.current` when no date is provided or when the provided date is invalid.
- The summary groups by `resource.building` and falls back to `Unknown` when the resource or building is missing.
- Overall totals are shown in a footer row below the per-building summary table.

---

Please implement these changes in the Rails app to add the admin Daily Summary report.
