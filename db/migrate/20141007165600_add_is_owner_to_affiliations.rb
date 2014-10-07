class AddIsOwnerToAffiliations < ActiveRecord::Migration
  def change
    add_column :affiliations, :is_owner, :boolean
  end
end
