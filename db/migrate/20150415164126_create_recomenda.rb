class CreateRecomenda < ActiveRecord::Migration
  def change
    create_table :recomenda do |t|
      t.integer :pesquisador1_id
      t.integer :pesquisador2_id
      t.integer :metodo_id
      t.float :value
      t.float :neighborhood
    end
  end
end
