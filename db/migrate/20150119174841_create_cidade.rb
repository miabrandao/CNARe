class CreateCidade < ActiveRecord::Migration
  def change
    create_table :cidade do |t|
      t.integer :estado_id
      t.string :nome
    end
  end
end
