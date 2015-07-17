class AddIndexToInct < ActiveRecord::Migration
  def change
    add_index :inct, :area_conhecimento_id
    add_index :inct, :inct_tema_id
    add_index :inct, :nome, :unique => true
  end
end
