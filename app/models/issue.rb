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

    
    def self.all_categories
    	["Incorrect Forms", "Under Review", "Pickup Required", "Other"]
    end

end
