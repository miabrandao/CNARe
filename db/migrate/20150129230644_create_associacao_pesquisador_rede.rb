class CreateAssociacaoPesquisadorRede < ActiveRecord::Migration
  def change
    create_table :associacao_pesquisador_rede do |t|
      t.integer :pesquisador_id
      t.integer :rede_id
    end
  end
end
