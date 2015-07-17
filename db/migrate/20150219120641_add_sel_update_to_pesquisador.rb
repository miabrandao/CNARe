class AddSelUpdateToPesquisador < ActiveRecord::Migration
  def change
    add_column :pesquisador, :sel_update, :integer
  end
end
