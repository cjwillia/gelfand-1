class BgCheck < ActiveRecord::Base

    # Relationships
    # -------------
    belongs_to :individual
    has_many :issues
    
	# Validations
	# -----------
    validates_date :date_requested, :allow_blank => true, :on_or_before => :today
    validates_date :criminal_date, :allow_blank => true
    validates_date :child_abuse_date, :allow_blank => true
    validates_date :fbi_date, :allow_blank => true

    # Callbacks
    # ---------

    before_save :set_dates
    before_create :set_initial_date
    before_create :set_created_status
    before_update :auto_update_status
    before_update :update_expired

    # Scopes
    # ------
    scope :alphabetical, -> { order('l_name, f_name') }
    scope :requested, -> { where('status = ?', 0) }
    scope :in_progress, -> { where('status = ?', 1) }
    scope :complete, -> { where('status = ?', 2) }
    scope :expiring, -> { where('status = ?', 4) }
    scope :expired, -> { where('status = ?', 5) }
    scope :has_issues, ->{ joins(:issues).group('bg_checks.id').merge(Issue.active).having('count(issues.id) > 0')}
    scope :incomplete, -> { where('status < ?', 2) }
    scope :not_cleared, -> { where('status = ?', 3) }
    scope :aging, -> { where('status > ?', 3).order('status DSC') }

    # Constants
    # ---------

    # forgot how to make this work
    # expiry_times = { "criminal" => 3.years, "child_abuse" => 3.years, "fbi" => 3.years }

    STATUS_LIST = [["Requested", 0], ["Clearances in Progress", 1], ["Completed", 2], ["Not Cleared", 3], ["Expiring", 4], ["Expired", 5]]

    # Class methods
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
                return "Clearances in Progress"
            when 2
                return "Completed"
            when 3
                return "Not Cleared"
            when 4
                return "Expiring"
            when 5
                return "Expired"
            else
                return "attr_error"
        end
    end

    def humanize_name
        "#{self.individual.f_name} #{self.individual.l_name}"
    end

    def clearances_remaining
        res = 3
        unless self.criminal_date.nil?
            res -= 1
        end
        unless self.child_abuse_date.nil?
            res -= 1
        end
        unless self.fbi_date.nil?
            res -= 1
        end
        return res
    end
   
    def update_expired
        if self.criminal_date.nil? || self.child_abuse_date.nil? || self.fbi_date.nil? || self.status < 2
            return
        end
        today = Date.today

        if self.criminal_date < today || self.child_abuse_date < today || self.fbi_date < today
            unless self.status === 5
                self.status = 5
                # Create an Issue in the background check
                @issue = Issue.new
                @issue.category = "Expiry"
                @issue.description = "One or more clearances have expired"
                @issue.bg_check_id = self.id
                @issue.save!
                #return true
            else
                #return false
            end
        elsif (self.criminal_date > today && self.criminal_date < today + 60.days) || (self.child_abuse_date > today && self.child_abuse_date < today + 60.days) || (self.fbi_date > today && self.fbi_date < today + 60.days)
                    unless self.status === 4
                    self.status = 4
                    # Create an Issue in the background check
                    @issue = Issue.new
                    @issue.category = "Expiry"
                    @issue.description = "One or more clearances are going to expire soon"
                    @issue.bg_check_id = self.id
                    @issue.save!
        end

        if self.criminal_date < today + 60.days || self.child_abuse_date < today + 60.days || self.fbi_date < today + 60.days
            if self.criminal_date < today || self.child_abuse_date < today || self.fbi_date < today

                    #return true
                else
                    #return false
                end
            else

            end
        end
        #return false
    end

    def update_expired?
        if self.criminal_date.nil? || self.child_abuse_date.nil? || self.fbi_date.nil? || self.status < 3
            return false
        end
        today = Date.today
        if self.criminal_date < today + 60.days || self.child_abuse_date < today + 60.days || self.fbi_date < today + 60.days
            if self.criminal_date > today || self.child_abuse_date > today || self.fbi_date > today
                unless self.status === 4
                    self.status = 4
                    # Create an Issue in the background check
                    @issue = Issue.new
                    @issue.category = "Expiry"
                    @issue.description = "One or more clearances are going to expire soon"
                    @issue.bg_check_id = self.id
                    @issue.save!
                    return true
                else
                    return false
                end
            else
                unless self.status === 5
                    self.status = 5
                    # Create an Issue in the background check
                    @issue = Issue.new
                    @issue.category = "Expiry"
                    @issue.description = "One or more clearances have expired"
                    @issue.bg_check_id = self.id
                    @issue.save!
                    return true
                else
                    return false
                end
            end
        end
        return false
    end

    private

    # Method to set the request date to the current date if there is no given date
    def set_initial_date
        unless date_requested
            self.date_requested = Date.today
        end
    end

    def set_dates
        if self.criminal_date
            self.criminal_date = self.criminal_date + 3.years
        end
        if self.child_abuse_date
            self.child_abuse_date = self.child_abuse_date + 3.years
        end
        if self.fbi_date
           self.fbi_date = self.fbi_date + 3.years
        end
    end

    def set_created_status
        unless self.status
            if self.criminal_date || self.child_abuse_date || self.fbi_date
                if self.criminal_date == nil || self.child_abuse_date == nil || self.fbi_date == nil
                    self.status = 1
                else
                    today = Date.today
                    if self.criminal_date < today || self.child_abuse_date < today || self.fbi_date < today
                        self.status = 5
                    elsif (self.criminal_date > today && self.criminal_date < today + 60.days) || (self.child_abuse_date > today && self.child_abuse_date < today + 60.days) || (self.fbi_date > today && self.fbi_date < today + 60.days)
                        self.status = 4
                    else
                        self.status = 2
                    end
                end
            else
                self.status = 0
            end
        end
    end

    # Method to update the status of a bg_check if the date is updated
    def auto_update_status
        if self.criminal_date && self.child_abuse_date && self.fbi_date
            if self.status < 2
                self.status = 2
            end
        elsif self.status == 2
            self.status = 1
        end
    end

end
