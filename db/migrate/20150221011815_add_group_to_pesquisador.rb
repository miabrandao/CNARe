class AddGroupToPesquisador < ActiveRecord::Migration
  def change
    add_column :pesquisador, :group, :integer
  end
end
