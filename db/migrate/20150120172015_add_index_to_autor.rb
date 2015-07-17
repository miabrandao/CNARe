class AddIndexToAutor < ActiveRecord::Migration
  def change
    add_index :autor, :pesquisador_id, :unique => true
  end
end
