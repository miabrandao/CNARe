class Publicacao < ActiveRecord::Base
  attr_accessible :autor_citacao_id, :coautores, :data_insercao, :data_publicacao, :doi, :dsc_coautores, :dsc_dataPublicacao, :dsc_titulo, :edicao_id, :id, :pagina, :publicacao_replica_id, :tema_id, :texto_citacao, :tipo_publicacao_id, :titulo
end
