class User < ActiveRecord::Base

    # Relationships
    # ------------- 
    has_many :org_users
    has_many :organizations, through: :org_users
    belongs_to :individual

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
  	admin # this is a boolean that holds a true or false value
  end

  def member?
  	member # this is a boolean that holds a true or false value
  end

  def get_org_ids
    org_ids = self.org_users.map{|ou| ou.org_id}
    org_ids
  end

  def get_prog_ids
    prog_ids = []
    org_ids = self.get_org_ids
    org_ids.each do |oi|
      Organization.find(oi).affiliations.program_id.each do |pi|
        prog_ids << pi
      end
    end
    prog_ids
  end

  def get_bg_check_id
    self.individual.bg_check.id
  end

  


end
