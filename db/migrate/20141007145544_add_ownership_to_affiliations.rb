class AddOwnershipToAffiliations < ActiveRecord::Migration
  def change
    add_column :affiliations, :ownership, :boolean
  end
end
