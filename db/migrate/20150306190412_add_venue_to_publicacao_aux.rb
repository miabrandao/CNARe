class AddVenueToPublicacaoAux < ActiveRecord::Migration
  def change
    add_column :publicacao_aux, :venue, :text
  end
end
