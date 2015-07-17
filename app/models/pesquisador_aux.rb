class PesquisadorAux < ActiveRecord::Base
  attr_accessible :acronym, :institution, :name, :research_area

  def self.import(file)
    if file.content_type == "text/csv"
      CSV.foreach(file.path, headers: true) do |row|
        pesquisador = find_by_name(row["name"]) || new
        pesquisador.attributes = row.to_hash.slice(*accessible_attributes)
        pesquisador.save!
      end
      return 1
    else
      return 0
    end
  end

end
