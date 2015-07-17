class CreateTema < ActiveRecord::Migration
  def change
    create_table :tema do |t|
      t.string :nome
    end
  end
end
