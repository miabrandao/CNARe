class AddAcronimoToInstituicao < ActiveRecord::Migration
  def change
    add_column :instituicao, :acronimo, :string
  end
end
