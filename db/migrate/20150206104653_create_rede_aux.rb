class CreateRedeAux < ActiveRecord::Migration
  def change
    create_table :rede_aux do |t|
      t.string :nome
    end
  end
end
