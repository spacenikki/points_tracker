class ChangeFfNoFormatInFfs < ActiveRecord::Migration
  def change
  	change_column :ffs, :ff_no, :string
  end
end
