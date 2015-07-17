class CreateMetodo < ActiveRecord::Migration
  def change
    create_table :metodo do |t|
      t.string :nome
    end
  end
end
