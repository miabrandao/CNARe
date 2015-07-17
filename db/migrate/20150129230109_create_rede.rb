class CreateRede < ActiveRecord::Migration
  def change
    create_table :rede do |t|
      t.string :nome
    end
  end
end
