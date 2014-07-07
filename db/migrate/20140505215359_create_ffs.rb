class CreateFfs < ActiveRecord::Migration
  def change
    create_table :ffs do |t|
      t.text :airline
      t.integer :ff_no
      t.integer :points
      t.integer :user_id

      t.timestamps
    end
  end
end
