class AddIndexToFormacaoAcademica < ActiveRecord::Migration
  def change
    add_index :formacao_academica, :instituicao_formacao_academica_id
    add_index :formacao_academica, :tipo_formacao_academica_id
    add_index :formacao_academica, :pesquisador_id
  end
end
