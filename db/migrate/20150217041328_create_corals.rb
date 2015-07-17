class CreateCorals < ActiveRecord::Migration
  def change
    create_table :corals do |t|
      t.integer :pesquisador1_id
      t.integer :pesquisador2_id
      t.float :value
    end
  end
end
