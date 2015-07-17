class CreatePesquisadorAux < ActiveRecord::Migration
  def change
    create_table :pesquisador_aux do |t|
      t.string :name
      t.text :research_area
      t.string :institution
      t.string :acronym
    end
  end
end
