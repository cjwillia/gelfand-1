class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :category
      t.text :description
      t.datetime :resolved
    end
  end
end
