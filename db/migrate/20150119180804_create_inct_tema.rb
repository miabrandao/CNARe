class CreateInctTema < ActiveRecord::Migration
  def change
    create_table :inct_tema do |t|
      t.string :nome
    end
  end
end
