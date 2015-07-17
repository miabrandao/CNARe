class CreatePublicacaoAux < ActiveRecord::Migration
  def change
    create_table :publicacao_aux do |t|
      t.text :title
      t.date :date_of_publication
      t.text :area
    end
  end
end
