require "rails_helper"

RSpec.describe Booking, type: :model do
  # Fix: auto_confirm was referenced in a before_validation callback
  # but the method didn't exist, so every Booking.create raised NoMethodError.
  describe "#auto_confirm" do
    it "sets status to confirmed by default on create" do
      booking = create(:booking, status: nil)
      expect(booking.status).to eq("confirmed")
    end

    it "does not overwrite an explicitly set status" do
      booking = create(:booking, status: :cancelled)
      expect(booking.status).to eq("cancelled")
    end
  end

  # Fix: confirm!, update_occupied_bitmap, clear_pending_bitmap
  # were below `private` so they couldn't be called from services.
  describe "public API methods" do
    let(:booking) { create(:booking) }

    it "responds to confirm! (was private before)" do
      expect(booking).to respond_to(:confirm!)
    end

    it "responds to update_occupied_bitmap (was private before)" do
      expect(booking).to respond_to(:update_occupied_bitmap)
    end

    it "responds to clear_pending_bitmap (was private before)" do
      expect(booking).to respond_to(:clear_pending_bitmap)
    end

    it "confirm! updates status to confirmed" do
      booking.update_column(:status, 1) # cancelled
      booking.reload
      booking.confirm!
      expect(booking.reload.status).to eq("confirmed")
    end
  end

  describe "validations" do
    it "is valid with valid factory attributes" do
      booking = build(:booking)
      expect(booking).to be_valid
    end

    it "rejects end_slot <= start_slot" do
      booking = build(:booking, start_slot: 20, end_slot: 18)
      expect(booking).not_to be_valid
      expect(booking.errors[:base]).to include("Invalid booking request")
    end

    it "rejects bookings in the past" do
      booking = build(:booking, booking_date: 1.day.ago.to_date)
      expect(booking).not_to be_valid
      expect(booking.errors[:booking_date]).to include("cannot be in the past")
    end

    it "rejects bookings outside operating hours" do
      booking = build(:booking, start_slot: 0, end_slot: 2)
      expect(booking).not_to be_valid
    end
  end
end
