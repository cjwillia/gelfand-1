class BgCheck < ActiveRecord::Base

    # Relationships
    # -------------
    belongs_to :individual
    
	# Validations
	# -----------
  	validates :status, :presence => true, :numericality => {:only_integer => true, :less_than_or_equal_to => 4, :greater_than_or_equal_to => 0}
    validates :individual_id, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0 }
    validates_date :date_requested, :allow_blank => false, :on_or_before => :today
    validates_date :criminal_date, :after => :date_requested, :allow_blank => true
    validates_date :child_abuse_date, :after => :criminal_date, :allow_blank => true

    # Callbacks
    # ---------

    before_create :give_initial_date

    # Scopes
    # ------
    scope :requested, -> { where('status = ?', 0) }
    scope :passed_criminal, -> { where('status = ?', 1) }
    scope :passed_child_abuse, -> { where('status = ?', 2) }
    scope :criminal_failed, -> { where('status = ?', 3) }
    scope :not_cleared, -> { where('status = ?', 4) }

   	# Class Methods
   	# -------------

   	def complete?
   		return self.status == 2
   	end

    def format_status
        case self.status
            when 0
                return "Requested"
            when 1
                return "Criminal Passed"
            when 2
                return "Child Abuse Passed"
            when 3
                return "Criminal Failed, Under Review"
            when 4
                return "Not Cleared"
            else
                return "attr_error"
        end
    end
    
    private

    # Method to set the request date to the current date if there is no given date
    def give_initial_date
        unless date_requested
            self.date_requested = Date.today
        end
    end

end
