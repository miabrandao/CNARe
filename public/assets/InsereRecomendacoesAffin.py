# coding=utf-8

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

#Inserindo as recomendações geradas pelo Affin...

cursor.execute("SELECT autor1, autor2, ((1 * importancia) + (100 * proximidade_social)) / (1 + 100) as value FROM recomendacao_local WHERE cooperacao = 0 AND (((((1 * importancia) + (100 * proximidade_social)) / (1 + 100)) > 2 / 3)) AND (autor1 != autor2) ORDER BY (((((1 * importancia) + (100 * proximidade_social)) / (1 + 100)) > 2 / 3)) DESC")

numrows = int(cursor.rowcount)

for recomendacao in cursor.fetchall():
  #Buscando o id do primeiro pesquisador...
  cursor.execute("SELECT pesquisador_id FROM autor WHERE id = {a1_id}".format(a1_id = recomendacao[0]))
  for pesquisador1 in cursor.fetchall():
    p1 = pesquisador1[0]
  #Buscando o id do segundo pesquisador...
  cursor.execute("SELECT pesquisador_id FROM autor WHERE id = {a2_id}".format(a2_id = recomendacao[1]))  
  for pesquisador2 in cursor.fetchall():
    p2 = pesquisador2[0]
  #Verificando se as recomendacoes já estão presentes nos banco...
  numrec = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {p1_id} AND pesquisador2_id = {p2_id} AND metodo_id = 2".format(p1_id = p1, p2_id = p2))
  if numrec == 0:
    #Inserindo a recomendacao no banco...
    cursor.execute("INSERT INTO recomenda (pesquisador1_id, pesquisador2_id, metodo_id, value) VALUES ({p1_id}, {p2_id}, 2, {val})".format(p1_id = p1, p2_id = p2, val = recomendacao[2]))  
    db.commit()

#Inserindo redes de coautoria...

cursor.execute("SELECT autor1, autor2 FROM recomendacao_local WHERE cooperacao != 0")

numrows = int(cursor.rowcount)

for coautoria in cursor.fetchall():
  #Buscando o id do primeiro pesquisador...
  cursor.execute("SELECT pesquisador_id FROM autor WHERE id = {a1_id}".format(a1_id = coautoria[0]))
  for pesquisador1 in cursor.fetchall():
    p1 = pesquisador1[0]
  #Buscando o id do segundo pesquisador...
  cursor.execute("SELECT pesquisador_id FROM autor WHERE id = {a2_id}".format(a2_id = coautoria[1]))  
  for pesquisador2 in cursor.fetchall():
    p2 = pesquisador2[0]
  #Verificando se os links já estão presentes nos banco...
  numco = cursor.execute("SELECT * FROM link WHERE source = {p1_id} AND target = {p2_id}".format(p1_id = p1, p2_id = p2))
  if numco == 0:
    #Inserindo o link no banco...
    cursor.execute("INSERT INTO link (source, target) VALUES ({p1_id}, {p2_id})".format(p1_id = p1, p2_id = p2))  
    db.commit()
    #verificando se este pesquisador foi recomendado...
    num_rec_affin = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 2".format(pesquisador1_id = p1, pesquisador2_id = p2))
    num_rec_corals = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 3".format(pesquisador1_id = p1, pesquisador2_id = p2))
    if num_rec_affin > 0:
      #excluindo possíveis recomendações
      cursor.execute("DELETE FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 2".format(pesquisador1_id = p1, pesquisador2_id = p2))
      db.commit()
    if num_rec_corals > 0:
      #excluindo possíveis recomendações
      cursor.execute("DELETE FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 3".format(pesquisador1_id = p1, pesquisador2_id = p2))
      db.commit()
