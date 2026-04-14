class AddPaymentFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :payment_expires_at, :datetime
    add_column :bookings, :paid_at, :datetime
    add_column :bookings, :total_cost, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :bookings, :stripe_session_id, :string
    add_index :bookings, :payment_expires_at, where: "status = 3", name: "idx_bookings_pending_payment_expiry"
  end
end
