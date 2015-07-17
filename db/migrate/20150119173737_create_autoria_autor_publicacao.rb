class CreateAutoriaAutorPublicacao < ActiveRecord::Migration
  def change
    create_table :autoria_autor_publicacao do |t|
      t.integer :autor_id
      t.integer :publicacao_id
      t.integer :ordem
    end
  end
end
