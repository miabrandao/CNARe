class AddIndexToEstado < ActiveRecord::Migration
  def change
    add_index :estado, :pais_id
  end
end
