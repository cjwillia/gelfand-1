class Organization < ActiveRecord::Base

    # Relationships
    # ------------- 
    belongs_to :contact
    has_many :affiliations
    has_many :programs, through: :affiliations
    has_many :org_users
    has_many :users, through: :org_users
    has_many :memberships
    has_many :individuals, through: :memberships

  # Scopes
  default_scope { where(active: true) }
  scope :alphabetical, -> { order('name') }
  scope :cmu_orgs, -> { where(is_partner: false) }
  scope :partner_orgs, -> { where(is_partner: true) }
  scope :inactive, -> { where(active: false) }

  # Validations
  validates_presence_of :name, :description, :department
  validates_uniqueness_of :name
  validates_format_of :department, :with => /^[ a-zA-Z]+$/, :multiline => true, 
  									:message => "Can only contain alphabetical characters, lower or uppercase"

  def get_memberships
    self.memberships
  end

  def get_all_individuals
    self.memberships.map{|mems| Individual.find(mems.individual_id) }
  end

  def get_membership_size
    self.memberships.length
  end


end
