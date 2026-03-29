# This model was missing entirely, but BookingLockService.acquire_lock
# calls Setting.get(:booking_lock_timeout_minutes, 5). Without this
# file that call raises NameError at runtime.
#
# The settings table + seed row already exist from the CreateSettings migration,
# so no new migration is needed — we just need the ActiveRecord model + getter.
class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Lookup a setting by key, returning `default` if the key doesn't exist.
  # Casts the stored string value based on value_type (integer, boolean, string).
  def self.get(key, default = nil)
    record = find_by(key: key.to_s)
    return default unless record

    cast_value(record.value, record.value_type)
  end

  private_class_method def self.cast_value(raw, type)
    case type
    when "integer" then raw.to_i
    when "boolean" then ActiveModel::Type::Boolean.new.cast(raw)
    else raw
    end
  end
end
