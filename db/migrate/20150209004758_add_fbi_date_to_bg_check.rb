class AddFbiDateToBgCheck < ActiveRecord::Migration
  def change
    add_column :bg_checks, :fbi_date, :date
  end
end
