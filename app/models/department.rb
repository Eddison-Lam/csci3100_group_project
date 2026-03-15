class Department < ApplicationRecord
  has_many :resources, dependent: :destroy
  has_many :admins, -> { admin }, class_name: "User"
  has_many :bookings, through: :resources

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }

  scope :active, -> { where(is_active: true) }

  def to_param
    code
  end
end
