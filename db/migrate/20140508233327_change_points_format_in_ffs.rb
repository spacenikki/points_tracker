class ChangePointsFormatInFfs < ActiveRecord::Migration
  def change
  	change_column :ffs, :points, :string
  end
end
