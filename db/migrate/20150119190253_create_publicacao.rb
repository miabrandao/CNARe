class CreatePublicacao < ActiveRecord::Migration
  def change
    create_table :publicacao do |t|
      t.integer :autor_citacao_id
      t.integer :publicacao_replica_id
      t.integer :edicao_id
      t.integer :tipo_publicacao_id
      t.text :titulo
      t.text :coautores
      t.text :doi
      t.date :data_publicacao
      t.date :data_insercao
      t.text :texto_citacao
      t.text :pagina
      t.text :dsc_coautores
      t.text :dsc_dataPublicacao
      t.text :dsc_titulo
      t.integer :tema_id
    end
  end
end
