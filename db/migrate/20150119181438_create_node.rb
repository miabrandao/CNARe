class CreateNode < ActiveRecord::Migration
  def change
    create_table :node do |t|
      t.string :name
      t.integer :group
    end
  end
end
