class CreatePais < ActiveRecord::Migration
  def change
    create_table :pais do |t|
      t.string :nome
      t.string :iso
      t.string :iso3
      t.integer :num_code
    end
  end
end
