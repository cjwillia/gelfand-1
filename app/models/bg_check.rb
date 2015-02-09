class BgCheck < ActiveRecord::Base

    # Relationships
    # -------------
    belongs_to :individual
    has_many :issues
    
	# Validations
	# -----------
  	validates :status, :numericality => {:only_integer => true, :less_than_or_equal_to => 6, :greater_than_or_equal_to => 0}
    validates :individual_id, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0 }
    validates_date :date_requested, :allow_blank => true, :on_or_before => :today
    validates_date :criminal_date, :allow_blank => true
    validates_date :child_abuse_date, :allow_blank => true
    validates_date :fbi_date, :allow_blank => true

    # Callbacks
    # ---------

    before_create :set_initial_date
    before_save :auto_update_status

    # Scopes
    # ------
    scope :alphabetical, -> {order('l_name, f_name')}
    scope :requested, -> { where('status = ?', 0) }
    scope :submitted, -> { where('status = ?', 1) }
    scope :in_progress, -> { where('status = ?', 2) }
    scope :picked_up, -> { where('status = ?', 3) }
    scope :expired, -> { where('bg_checks.child_abuse_date <= ?', Date.today<<36)}
    scope :has_issues, ->{ joins(:issues).group('bg_checks.id').merge(Issue.active).having('count(issues.id) > 0')}
    scope :incomplete, -> { where('status < ?', 3)}

    # Class meethods
    # ----------------
    def self.order_by_urgency bg_checks
        checks = bg_checks.delete_if {|bg_c|bg_c.individual.days_till_program==nil||bg_c.individual.days_till_program<0}
        checks = checks.sort {|x,y|x.individual.days_till_program <=> y.individual.days_till_program}
    end

   	# Instance Methods
   	# ----------------

    def format_status
        case self.status
            when 0
                return "Requested"
            when 1
                return "Submitted"
            when 2
                return "Clearances in Progress"
            when 3
                return "Picked Up/Mailed"
            when 4
                return "Not Cleared"
            when 5
                return "Expired"
            else
                return "attr_error"
        end
    end

    def humanize_name
        "#{self.individual.f_name} #{self.individual.l_name}"
    end
   
    private

    # Method to set the request date to the current date if there is no given date
    def set_initial_date
        unless date_requested
            self.date_requested = Date.today
        end
    end

    def set_initial_status
        self.status = 0
    end

    # Method to update the status of a bg_check if the date is updated
    def auto_update_status
        if self.criminal_date && self.child_abuse_date && self.fbi_date && self.status < 3
            self.status = 3
        end
    end

end
