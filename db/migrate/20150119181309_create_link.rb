class CreateLink < ActiveRecord::Migration
  def change
    create_table :link do |t|
      t.integer :source
      t.integer :target
      t.integer :value
      t.integer :last_year_pub_target
      t.integer :count_pub_target
    end
  end
end
