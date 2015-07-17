class CreateAutorPublicacaoInstituicao < ActiveRecord::Migration
  def change
    create_table :autor_publicacao_instituicao, :id => false do |t|
      t.integer :autor_id
      t.integer :inct_id
      t.integer :instituicao_id
      t.integer :publicacao_id
    end
  end
end
