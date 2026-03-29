require "rails_helper"

# Fix: Setting model was completely missing
# BookingLockService.acquire_lock calls Setting.get(:booking_lock_timeout_minutes, 5)
# and would crash with NameError without this model.
RSpec.describe Setting, type: :model do
  describe "validations" do
    it "requires a key" do
      setting = Setting.new(key: nil, value: "test")
      expect(setting).not_to be_valid
      expect(setting.errors[:key]).to include("can't be blank")
    end

    it "requires key to be unique" do
      create(:setting, key: "unique_key")
      duplicate = build(:setting, key: "unique_key")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:key]).to include("has already been taken")
    end
  end

  describe ".get" do
    it "returns the value for an existing key" do
      Setting.create!(key: "site_name", value: "CUHK Booking", value_type: "string")
      expect(Setting.get(:site_name)).to eq("CUHK Booking")
    end

    it "returns the default when key does not exist" do
      expect(Setting.get(:nonexistent, "fallback")).to eq("fallback")
    end

    it "returns nil when key missing and no default given" do
      expect(Setting.get(:nonexistent)).to be_nil
    end

    it "casts integer value_type to Integer" do
      Setting.create!(key: "timeout", value: "42", value_type: "integer")
      result = Setting.get(:timeout)
      expect(result).to eq(42)
      expect(result).to be_a(Integer)
    end

    it "casts boolean value_type to true/false" do
      Setting.create!(key: "flag_on", value: "true", value_type: "boolean")
      Setting.create!(key: "flag_off", value: "false", value_type: "boolean")
      expect(Setting.get(:flag_on)).to be(true)
      expect(Setting.get(:flag_off)).to be(false)
    end

    it "returns raw string for string value_type" do
      Setting.create!(key: "greeting", value: "hello", value_type: "string")
      expect(Setting.get(:greeting)).to eq("hello")
    end
  end
end
