class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resource, null: false, foreign_key: true
      t.date    :booking_date, null: false
      t.integer :start_slot, null: false
      t.integer :end_slot, null: false
      t.integer :status, default: 0, null: false    # enum: pending, confirmed, rejected, (canceled?)

      t.string   :purpose
      t.text     :notes
      t.text     :rejection_reason
      t.datetime :responded_at
      t.references :approved_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true

      t.timestamps
    end

    add_index :bookings, [ :resource_id, :booking_date, :status ], name: "idx_bookings_availability"
    add_index :bookings, [ :user_id, :booking_date ], name: "idx_bookings_user_date"
  end
end
