class AddIndexToAutoriaAutorPublicacao < ActiveRecord::Migration
  def change
    add_index :autoria_autor_publicacao, :autor_id
    add_index :autoria_autor_publicacao, :publicacao_id
  end
end
