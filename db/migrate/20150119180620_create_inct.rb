class CreateInct < ActiveRecord::Migration
  def change
    create_table :inct do |t|
      t.integer :area_conhecimento_id
      t.integer :inct_tema_id
      t.string :nome
      t.text :link_oficial
      t.text :link_2
    end
  end
end
