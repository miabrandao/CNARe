class CreateAutor < ActiveRecord::Migration
  def change
    create_table :autor do |t|
      t.integer :pesquisador_id
      t.integer :modclass
      t.integer :selecao
    end
  end
end
