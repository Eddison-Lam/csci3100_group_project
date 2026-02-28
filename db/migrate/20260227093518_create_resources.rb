class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string  :type, null: false            # STI: Room / Equipment
      t.string  :name, null: false
      t.text    :description
      t.references :department, null: false, foreign_key: true

      # Booking limit
      t.integer :max_slots_per_booking
      t.integer :min_slots_per_booking, default: 1
      t.integer :advance_booking_days, default: 14
      t.integer :operating_start_slot, default: 16
      t.integer :operating_end_slot,   default: 44

      t.decimal :price_per_unit, precision: 10, scale: 2, default: 0.0
      t.boolean :is_active, default: true, null: false
      t.boolean :requires_approval, default: false, null: false

      # Room-specific attributes
      t.string  :building
      t.string  :room_type
      t.integer :capacity
      t.string  :location                      # detail loc e.g. "2/F Room 201"

      # Equipment-specific attributes
      t.integer :quantity, default: 1

      t.timestamps
    end
    add_index :resources, :type
    add_index :resources, :building
    add_index :resources, :room_type
  end
end
