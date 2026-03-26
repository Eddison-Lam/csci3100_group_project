# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { student: 0, admin: 1, superadmin: 2 }

  belongs_to :department, optional: true
  has_many :bookings, dependent: :destroy

  validates :email, presence: true
  validate :validate_cuhk_email_domain
  # Changed from `if: :admin?` to also require `persisted?`.
  # Without this, Devise registration for @cuhk.edu.hk emails would crash
  # because assign_role_from_email auto-sets role to :admin, but Devise
  # sign-up has no department field. Now admins can register first and
  # get a department assigned later by a superadmin.
  validates :department, presence: true, if: -> { admin? && persisted? }

  before_validation :assign_role_from_email, on: :create

  def can_manage?(resource)
    superadmin? || (admin? && department_id == resource.department_id)
  end

  private

  def validate_cuhk_email_domain
    return if email.blank?

    valid_domains = [
      "@link.cuhk.edu.hk",  # stduents
      "@cuhk.edu.hk",       # staff and depts
      "@e.cuhk.edu.hk"      # retirees
    ]

    unless valid_domains.any? { |domain| email.downcase.ends_with?(domain) }
      errors.add(:email, "Must be a CUHK email address (@link.cuhk.edu.hk, @cuhk.edu.hk, or @e.cuhk.edu.hk)")
    end

    # basic format check
    username = email.split("@").first
    if username.blank? || username.include?(" ") || username.starts_with?(".") || username.ends_with?(".")
      errors.add(:email, "Invalid email format")
    end
  end

  def assign_role_from_email
    return if role.present? && superadmin?

    # Trust the email domain to assign roles: (Bad practice but simplifies user management) (maybe allow superadmin to override this in the future)
    # 1. @link.cuhk.edu.hk → default as student
    # 2. @cuhk.edu.hk or @e.cuhk.edu.hk → default as admin（need activation）

    if email&.downcase&.include?("@link.cuhk.edu.hk")
      self.role = :student
    elsif email&.downcase&.match?(/@(cuhk|e\.cuhk)\.edu\.hk\z/)
      self.role = :admin
    end
  end
end
