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

    email_down = email.downcase.strip

    if email_down == "admin@cuhk.edu.hk"
      validate_basic_email_format
      return
    end

    if email_down.ends_with?("@link.cuhk.edu.hk")
      validate_basic_email_format
      return
    end

    if match = email_down.match(/@([a-z0-9-]+)\.cuhk\.edu\.hk\z/i)
      dept_code = match[1]

      if dept_code.length < 2 || dept_code.match?(/\A\d+\z/)
        errors.add(:email, "Invalid department code in email")
        return
      end

      validate_basic_email_format
      return
    end

    errors.add(:email, "Must be a valid CUHK email: @link.cuhk.edu.hk (students) or name@deptcode.cuhk.edu.hk (admins)")
  end

  def validate_basic_email_format
    username = email.split("@").first.to_s.strip

    if username.blank? ||
      username.include?(" ") ||
      username.starts_with?(".") ||
      username.ends_with?(".")
      errors.add(:email, "Invalid email format")
    end
  end

  def assign_role_from_email
    return if role.present? && superadmin?

    # Trust the email domain to assign roles: (Bad practice but simplifies user management) (maybe allow superadmin to override this in the future)
    # 1. @link.cuhk.edu.hk → default as student
    # 2. @cuhk.edu.hk or @e.cuhk.edu.hk → default as admin（need activation）

    email_down = email.downcase.strip

    if email_down.include?("@link.cuhk.edu.hk")
      self.role = :student
      self.department_id = nil

    elsif match = email_down.match(/@([a-z0-9-]+)\.cuhk\.edu\.hk\z/i)
      dept_code = match[1]

      self.role = :admin

      department = Department.find_by(code: dept_code) ||
                  Department.create!(
                    name: dept_code.upcase,
                    code: dept_code
                  )
      self.department_id = department.id
    elsif email_down== ("admin@cuhk.edu.hk")
      self.role = :superadmin
      self.department_id = nil
    end
  end
end
