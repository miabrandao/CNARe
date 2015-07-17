class CreateAreaConhecimento < ActiveRecord::Migration
  def change
    create_table :area_conhecimento do |t|
      t.string :nome
    end
  end
end
