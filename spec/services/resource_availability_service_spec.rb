require "rails_helper"

# Fix 1: Redis was inconsistent (Redis.current vs Redis.new).
# Fix 2: Booking called class methods that didn't exist on this service.
RSpec.describe ResourceAvailabilityService do
  let(:department) { create(:department) }
  let(:resource)   { create(:resource, :room, department: department) }

  before do
    # Clean Redis keys before each test so state doesn't leak between examples
    REDIS.keys("occupied:*").each  { |k| REDIS.del(k) }
    REDIS.keys("pending:*").each   { |k| REDIS.del(k) }
    REDIS.keys("locks:*").each     { |k| REDIS.del(k) }
    REDIS.keys("slot_lock:*").each { |k| REDIS.del(k) }
  end

  # Fix: Verify the service uses the shared REDIS constant
  # instead of the deprecated Redis.current
  describe "Redis connection" do
    it "uses the shared REDIS constant from the initializer" do
      service = described_class.new(resource)
      # The private redis method should return the REDIS constant
      expect(service.send(:redis)).to eq(REDIS)
    end
  end

  # Fix: These class methods were missing; Booking model calls them.
  describe ".update_occupied_bitmap" do
    it "responds to the class method" do
      expect(described_class).to respond_to(:update_occupied_bitmap)
    end

    it "marks slots as occupied in Redis" do
      date = 1.day.from_now.to_date
      slots = [16, 17, 18]
      described_class.update_occupied_bitmap(resource.id, date, slots)

      key = format(described_class::OCCUPIED_KEY, resource_id: resource.id, date: date.to_s)
      # Verify the bits were set by checking via getbit
      slots.each do |slot|
        expect(REDIS.getbit(key, slot)).to eq(1)
      end
    end
  end

  describe ".clear_pending_bitmap" do
    it "responds to the class method" do
      expect(described_class).to respond_to(:clear_pending_bitmap)
    end

    it "clears pending slots in Redis" do
      date = 1.day.from_now.to_date
      key = format(described_class::PENDING_KEY, resource_id: resource.id, date: date.to_s)

      # Set some pending bits first
      [16, 17, 18].each { |slot| REDIS.setbit(key, slot, 1) }

      # Clear them
      described_class.clear_pending_bitmap(resource.id, date, [16, 17, 18])

      [16, 17, 18].each do |slot|
        expect(REDIS.getbit(key, slot)).to eq(0)
      end
    end
  end

  describe "#set_occupied_slots" do
    it "is a public instance method (was private before)" do
      service = described_class.new(resource)
      expect(service).to respond_to(:set_occupied_slots)
    end
  end

  describe "#set_pending_slots" do
    it "is a public instance method (was private before)" do
      service = described_class.new(resource)
      expect(service).to respond_to(:set_pending_slots)
    end
  end

  describe "#clear_pending_slots" do
    it "is a public instance method (was private before)" do
      service = described_class.new(resource)
      expect(service).to respond_to(:clear_pending_slots)
    end
  end
end
