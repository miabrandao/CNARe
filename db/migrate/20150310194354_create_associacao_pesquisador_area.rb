class CreateAssociacaoPesquisadorArea < ActiveRecord::Migration
  def change
    create_table :associacao_pesquisador_area do |t|
      t.integer :pesquisador_id
      t.integer :area_id
    end
  end
end
