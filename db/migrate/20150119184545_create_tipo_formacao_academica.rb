class CreateTipoFormacaoAcademica < ActiveRecord::Migration
  def change
    create_table :tipo_formacao_academica do |t|
      t.string :nome
    end
  end
end
