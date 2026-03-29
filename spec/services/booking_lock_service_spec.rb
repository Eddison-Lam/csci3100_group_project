require "rails_helper"

# Fix 1: This service calls Setting.get which used to crash with NameError.
# Fix 2: This service was creating its own Redis.new, now uses shared REDIS.
RSpec.describe BookingLockService do
  let(:department) { create(:department) }
  let(:resource)   { create(:resource, :room, department: department) }
  let(:user)       { create(:user) }
  let(:date)       { 1.day.from_now.to_date }

  before do
    # Clean Redis keys before each test
    REDIS.keys("booking_lock:*").each    { |k| REDIS.del(k) }
    REDIS.keys("resource_locks:*").each  { |k| REDIS.del(k) }
    REDIS.keys("slot_lock:*").each       { |k| REDIS.del(k) }

    # Make sure the Setting row exists so acquire_lock doesn't crash.
    # This proves Fix 1 (Setting model) works end-to-end with this service.
    Setting.find_or_create_by!(key: "booking_lock_timeout_minutes") do |s|
      s.value = "5"
      s.value_type = "integer"
    end
  end

  # Fix: Verify it uses the shared REDIS constant
  describe "Redis connection" do
    it "uses the shared REDIS constant from the initializer" do
      expect(described_class.send(:redis)).to eq(REDIS)
    end
  end

  describe ".acquire_lock" do
    it "returns a lock token for available slots" do
      token = described_class.acquire_lock(
        user: user, resource: resource, date: date,
        start_slot: 16, end_slot: 18
      )
      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it "returns nil when slots are already locked" do
      # Acquire first lock
      described_class.acquire_lock(
        user: user, resource: resource, date: date,
        start_slot: 16, end_slot: 18
      )
      # Try to lock the same slots — should fail
      other_user = create(:user)
      token2 = described_class.acquire_lock(
        user: other_user, resource: resource, date: date,
        start_slot: 16, end_slot: 18
      )
      expect(token2).to be_nil
    end
  end

  describe ".validate_lock" do
    it "returns true for a valid lock belonging to the user" do
      token = described_class.acquire_lock(
        user: user, resource: resource, date: date,
        start_slot: 16, end_slot: 18
      )
      expect(described_class.validate_lock(token, user.id)).to be(true)
    end

    it "returns false for a different user" do
      token = described_class.acquire_lock(
        user: user, resource: resource, date: date,
        start_slot: 16, end_slot: 18
      )
      other_user = create(:user)
      expect(described_class.validate_lock(token, other_user.id)).to be(false)
    end
  end

  describe ".release_lock" do
    it "deletes the lock from Redis" do
      token = described_class.acquire_lock(
        user: user, resource: resource, date: date,
        start_slot: 16, end_slot: 18
      )
      expect(described_class.release_lock(token)).to be(true)
      expect(described_class.get_lock(token)).to be_nil
    end
  end
end
