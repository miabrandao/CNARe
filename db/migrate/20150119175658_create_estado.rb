class CreateEstado < ActiveRecord::Migration
  def change
    create_table :estado do |t|
      t.integer :pais_id
      t.string :sigla
      t.string :nome
    end
  end
end
