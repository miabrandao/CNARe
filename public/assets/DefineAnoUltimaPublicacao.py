# coding=utf-8
  
def PesquisadorToAutor(pesquisador_id):
  cursor.execute("SELECT id FROM autor WHERE pesquisador_id = {s_id}".format(s_id = pesquisador_id))
  for autor_id in cursor.fetchall():
    return autor_id[0]

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("SELECT DISTINCT source FROM link WHERE last_year_pub_target is null")

numrows = int(cursor.rowcount)

#lista de publicações do source autor...
lista_publicacoes_source = []

#Número máximo de publicações em comum...
max_year = 0


for pesquisadores_id in cursor.fetchall():
  #buscando o numero de identificação de autor dos sources...
  autor_source_id = PesquisadorToAutor(pesquisadores_id[0])
  #buscando a lista de publicações deste pesquisador...
  x = cursor.execute("SELECT publicacao_id FROM autoria_autor_publicacao WHERE autor_id = {a_id}".format(a_id = autor_source_id))
  if x > 1: 
    cursor.execute("SELECT publicacao_id FROM autoria_autor_publicacao WHERE autor_id = {a_id}".format(a_id = autor_source_id))
    for pubs_source in cursor.fetchall():  
      lista_publicacoes_source.append(int(pubs_source[0]))
  elif x == 1:
    cursor.execute("SELECT publicacao_id FROM autoria_autor_publicacao WHERE autor_id = {a_id}".format(a_id = autor_source_id))
    for pubs_source in cursor.fetchall():  
      pub = pubs_source[0]
  #buscando o numero de identificação de autor dos targets...
  cursor.execute("SELECT DISTINCT target FROM link WHERE source = {s_id}".format(s_id = pesquisadores_id[0]))
  for pesquisadores2_id in cursor.fetchall():
    autor_target_id = PesquisadorToAutor(pesquisadores2_id[0])
    #buscando o id das publicações em comum entre os dois pesquisadores
    if x > 1:
      cursor.execute("SELECT publicacao_id FROM autoria_autor_publicacao WHERE autor_id = {a_id} AND publicacao_id in {lista_pubs}".format(a_id = autor_target_id, lista_pubs = tuple(lista_publicacoes_source)))
    elif x == 1:
      cursor.execute("SELECT publicacao_id FROM autoria_autor_publicacao WHERE autor_id = {a_id} AND publicacao_id = {lista_pubs}".format(a_id = autor_target_id, lista_pubs = pub))
    #buscando o ano da ultima publicacao 
    for pubs_in_common in cursor.fetchall():
      cursor.execute("SELECT year(data_publicacao) FROM publicacao WHERE id = {p_id}".format(p_id = pubs_in_common[0])) 
      for year_pub in cursor.fetchall():
        if max_year < year_pub[0]:
          max_year = year_pub[0] 
    if max_year > 0:
      #Atualizando a tabela link com a data da última publicação em comum...
      cursor.execute("UPDATE link SET last_year_pub_target = {year} WHERE (source = {source} AND target = {target}) OR (source = {source2} AND target = {target2})".format(year = max_year, source = pesquisadores_id[0], target = pesquisadores2_id[0], source2 = pesquisadores2_id[0], target2 = pesquisadores_id[0]))
      db.commit()
  #zerando a variável que indica o ano da ultima publicacão em comum... 
  max_year = 0
  #limpando a lista de publicações...
  lista_publicacoes_source = []
