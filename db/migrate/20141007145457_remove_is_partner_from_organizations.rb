class RemoveIsPartnerFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :is_partner, :boolean
  end
end
