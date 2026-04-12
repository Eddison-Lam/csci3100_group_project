class AddStripeSessionToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :stripe_session_id, :string
  end
end
