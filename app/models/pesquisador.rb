class Pesquisador < ActiveRecord::Base
  attr_accessible :area, :data_coleta_lattes, :id, :instituicao, :nivel_coleta, :nome, :nomeDsc, :selecao, :sexo, :ult_data_atualizacao_lattes, :url_lattes, :url_lattes_oficial

  has_many :recomendas
  has_many :pesquisadors2, :through => :recomendas, 
                                     :source => :pesquisador2

  def self.search(search)
    if search != ""
      find(:all, :conditions => ['nome like ?', "%#{search}%"])
    else
      find(:all, :conditions => ['nome like ?', "%55557879sjaiuad%"])
    end
  end

end
