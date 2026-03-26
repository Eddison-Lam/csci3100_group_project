require "rails_helper"

RSpec.describe User, type: :model do
  # Fix: Admin registration was blocked because
  # `validates :department, presence: true, if: :admin?` triggered on create.
  # Staff emails auto-assign role=admin via assign_role_from_email, but
  # Devise sign-up doesn't have a department field, so validation crashed.
  # Fix: only enforce department presence on persisted (existing) admins.
  describe "admin registration without department" do
    it "allows a new admin to register without a department" do
      user = User.new(
        email: "newstaff@cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123"
      )
      # assign_role_from_email will set role to :admin
      expect(user).to be_valid
      expect(user.save).to be(true)
      expect(user.role).to eq("admin")
      expect(user.department).to be_nil
    end

    it "requires department for an existing (persisted) admin on update" do
      user = User.create!(
        email: "existingstaff@cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123"
      )
      expect(user).to be_persisted
      expect(user.role).to eq("admin")

      # Now that they're persisted, department should be required
      user.email = "updatedstaff@cuhk.edu.hk"
      expect(user).not_to be_valid
      expect(user.errors[:department]).to include("can't be blank")
    end

    it "does not require department for students" do
      user = User.new(
        email: "student@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123"
      )
      expect(user).to be_valid
      expect(user.role).to eq("student")
    end
  end

  describe "role assignment" do
    it "assigns student role for @link.cuhk.edu.hk emails" do
      user = create(:user, email: "s1234@link.cuhk.edu.hk")
      expect(user.role).to eq("student")
    end

    it "assigns admin role for @cuhk.edu.hk emails" do
      user = create(:user, email: "prof@cuhk.edu.hk")
      expect(user.role).to eq("admin")
    end

    it "assigns admin role for @e.cuhk.edu.hk emails" do
      user = create(:user, email: "retired@e.cuhk.edu.hk")
      expect(user.role).to eq("admin")
    end
  end

  describe "email validation" do
    it "rejects non-CUHK emails" do
      user = build(:user, email: "test@gmail.com")
      expect(user).not_to be_valid
      expect(user.errors[:email].join).to include("CUHK")
    end
  end
end
