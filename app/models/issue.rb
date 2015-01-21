class Issue < ActiveRecord::Base

    # Relationships
    # -------------
    belongs_to :bg_check

    scope :active, -> { where(resolved: nil) }

    # Validations
    # -------------
    validates_presence_of :category
    validates_presence_of :description

    # Scopes
    # ------

    scope :active, -> { where(resolved: nil) }
    scope :inactive, -> { where("resolved IS NOT NULL") }
    scope :by_relevance, -> { order("resolved ASC") }

    
    def self.all_categories
    	["Submission", "Criminal Clearance", "Child Abuse Clearance", "Other"]
    end

    def self.descriptions
        [
            "Missing forms(s) -- Must submit all 3 forms",
            "Missing signature on at least one form",
            "Failure to use a Pennsylvania address on Child Abuse Clearance form",
            "Failure to list home address and all other addresses in the 'other addresses' section of the Child Abuse Clearance form",
            "Failure to list roommates or family members on the Child Abuse Clearance form",
            "Forms were completed in pencil (they must be in ink)",
            "Requestor did not state the program(s) or course(s) for which they will volunteer",
            "Form is a photocopy or scanned form without an original signature",
            "Previous clearance is still valid; we will NOT submit a request to get a new original copy of the certificate if it has been lost",
            "Request is under review; requestor is not permitted to work with children"
        ]
    end



    def active?
        return self.resolved.nil?
    end

end
