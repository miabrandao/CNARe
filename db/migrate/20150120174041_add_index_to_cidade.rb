class AddIndexToCidade < ActiveRecord::Migration
  def change
    add_index :cidade, :estado_id
  end
end
