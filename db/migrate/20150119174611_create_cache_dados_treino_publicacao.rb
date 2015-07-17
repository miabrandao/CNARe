class CreateCacheDadosTreinoPublicacao < ActiveRecord::Migration
  def change
    create_table :cache_dados_treino_publicacao, :id => false do |t|
      t.integer :tema_id
      t.string :titulo
    end
  end
end
