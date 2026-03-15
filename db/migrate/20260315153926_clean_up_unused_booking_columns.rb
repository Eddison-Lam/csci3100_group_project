class CleanUpUnusedBookingColumns < ActiveRecord::Migration[8.1]
  def change
    remove_reference :bookings, :approved_by, foreign_key: { to_table: :users }, if_exists: true
    remove_column :bookings, :responded_at, :datetime, if_exists: true
    remove_column :bookings, :rejection_reason, :text, if_exists: true
  end
end
