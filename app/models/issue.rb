class Issue < ActiveRecord::Base

    # Relationships
    # -------------
    belongs_to :bg_check

    # Validations
    # -------------
    validates_presence_of :category
    validates_presence_of :description

end
