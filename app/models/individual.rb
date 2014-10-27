class Individual < ActiveRecord::Base

    # Relationships
    # -------------
    belongs_to :contact
    has_many :memberships
    has_many :organizations, through: :memberships
    has_many :participants
    has_many :programs, through: :participants
    has_one :bg_check
    belongs_to :user


    validates :f_name, :presence => true
    validates :l_name, :presence => true

    # TBD by future ERD
    validates :role, :presence => true, :numericality => {:only_integer => true, :less_than_or_equal_to => 3, :greater_than_or_equal_to => 0}


    # Callbacks
    # ---------
    before_create :set_defaults

    # Scopes
    # ------
    default_scope { where(active: true) }
    scope :alphabetical, -> { order('l_name') }
    scope :alpha_by_first, -> { order('f_name') }
    scope :students, -> { where(role: 0) }
    scope :faculty, -> { where(role: 1) }
    scope :off_campus, -> { where(role: 2) }
    scope :inactive, -> { where(active: false) }

    # Select Lists
    # -------
    
    ROLES_LIST = [["CMU Student", 0],["CMU Faculty", 1],["CMU Staff", 2],["External Contractor", 3]]

    # Class Methods
    # -------------

    def format_role
    	case self.role
            when 0
                return "Student"
            when 1
                return "Staff"
            when 2
                return "Faculty"
            when 3
<<<<<<< HEAD
                return "Contractor"
=======
                return "External Contractor"
>>>>>>> 8a35adb08615e432a730f89d0db40c4e9ef81971
            else
                return "Unknown"
    	end
    end

	def name
		"#{l_name}, #{f_name}"
	end

	def proper_name
		"#{f_name} #{l_name}"
	end

    def bg_check_complete?
        unless self.bg_check.nil?
            return self.bg_check.complete?
        end
        return false
    end

    # Private Methods
    # ---------------
    private
    
    	def set_defaults
    		self.active = true
    	end



end
