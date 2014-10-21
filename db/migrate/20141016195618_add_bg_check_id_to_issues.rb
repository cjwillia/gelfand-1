class AddBgCheckIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :bg_check_id, :integer
  end
end
