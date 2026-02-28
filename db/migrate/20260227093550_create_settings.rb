class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value
      t.string :value_type, default: 'string'           # string, integer, boolean
      t.text :description

      t.timestamps
    end

    add_index :settings, :key, unique: true

    # default settings
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO settings (`key`, `value`, value_type, description, created_at, updated_at)
          VALUES ('booking_lock_timeout_minutes', '5', 'integer', 'Minutes before a booking lock expires', NOW(), NOW())
        SQL
      end
    end
  end
end
