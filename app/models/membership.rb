class Membership < ActiveRecord::Base
    before_create :make_active


    # Relationships
    # ------------- 
    belongs_to :individual
    belongs_to :organization

    scope :for_individual, lambda {|individual_id| where("individual_id = ?", individual_id) }
    scope :for_organization, lambda {|organization_id| where("organization_id = ?", organization_id) }


    def make_active
        self.active = true
    end

end
