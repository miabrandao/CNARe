class PublicacaoAux < ActiveRecord::Base
  attr_accessible :area, :date_of_publication, :title, :authors, :venue

  def self.import(file)
    if file.content_type == "text/csv"
      CSV.foreach(file.path, headers: true) do |row|
        publicacao = find_by_title(row["title"]) || new
        publicacao.attributes = row.to_hash.slice(*accessible_attributes)
        publicacao.save!
      end
      return 1
    else
      return 0
    end
  end

end
