# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def self.up
    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      # t.string  :name, null: false, default: ""
      t.string :student_id
      t.references :department, null: true, foreign_key: { on_delete: :nullify }
      t.integer :role, default: 0, null: false

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :student_id,           unique: true
    add_index :users, :role
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
