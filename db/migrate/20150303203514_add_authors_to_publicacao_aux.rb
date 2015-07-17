class AddAuthorsToPublicacaoAux < ActiveRecord::Migration
  def change
    add_column :publicacao_aux, :authors, :text
  end
end
