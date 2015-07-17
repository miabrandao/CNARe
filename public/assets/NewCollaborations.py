# coding=utf-8
  
def PesquisadorToAutor(pesquisador_id):
  cursor.execute("SELECT id FROM autor WHERE pesquisador_id = {s_id}".format(s_id = pesquisador_id))
  for autor_id in cursor.fetchall():
    return autor_id[0]

def AutorToPesquisador(autor_id):
  cursor.execute("SELECT pesquisador_id FROM autor WHERE id = {a_id}".format(a_id = autor_id))
  for pesquisador_id in cursor.fetchall():
    return pesquisador_id[0]

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("SELECT DISTINCT id FROM pesquisador WHERE sel_update = 1")

numrows = int(cursor.rowcount)

for source_id in cursor.fetchall():
  #buscando o id autor do pesquisador...
  source_autor_id = PesquisadorToAutor(source_id[0])
  #buscando as publicações deste pesquisador...
  cursor.execute("SELECT publicacao_id FROM autoria_autor_publicacao WHERE autor_id = {autor_id}".format(autor_id = source_autor_id))
  for publicacoes_id in cursor.fetchall():
    #procurando autores em comum...
    cursor.execute("SELECT autor_id FROM autoria_autor_publicacao WHERE publicacao_id = {publicacao_id} AND autor_id <> {autor_id}".format(publicacao_id = publicacoes_id[0], autor_id = source_autor_id))
    for target_autor_id in cursor.fetchall():
      target_pesquisador_id = AutorToPesquisador(target_autor_id[0])
      #verificando se a colaboração já está presente no banco...
      num_links = cursor.execute("SELECT * FROM link WHERE source = {source} AND target = {target}".format(source = source_id[0], target = target_pesquisador_id))
      if num_links == 0:
        #inserindo uma nova colaboração no banco...
        cursor.execute("INSERT INTO link (source, target) VALUES ({source}, {target})".format(source = source_id[0], target = target_pesquisador_id))
        db.commit()
        #verificando se este pesquisador foi recomendado...
        num_rec_affin = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 2".format(pesquisador1_id = source_id[0], pesquisador2_id = target_pesquisador_id))
        num_rec_corals = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 3".format(pesquisador1_id = source_id[0], pesquisador2_id = target_pesquisador_id))
        if num_rec_affin > 0:
          #excluindo possíveis recomendações
          cursor.execute("DELETE FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 2".format(pesquisador1_id = source_id[0], pesquisador2_id = target_pesquisador_id))
          db.commit()
        if num_rec_corals > 0:
          #excluindo possíveis recomendações
          cursor.execute("DELETE FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 3".format(pesquisador1_id = source_id[0], pesquisador2_id = target_pesquisador_id))
          db.commit()
      #mesma coisa de antes, só que inversamente
      num_links = cursor.execute("SELECT * FROM link WHERE source = {source} AND target = {target}".format(source = target_pesquisador_id, target = source_id[0]))
      if num_links == 0:
        cursor.execute("INSERT INTO link (source, target) VALUES ({source}, {target})".format(source = target_pesquisador_id, target = source_id[0]))
        db.commit()
        #verificando se este pesquisador foi recomendado...
        num_rec_affin = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 2".format(pesquisador1_id = target_pesquisador_id, pesquisador2_id = source_id[0]))
        num_rec_corals = cursor.execute("SELECT * FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 3".format(pesquisador1_id = target_pesquisador_id, pesquisador2_id = source_id[0]))
        if num_rec_affin > 0:
          #excluindo possíveis recomendações
          cursor.execute("DELETE FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 2".format(pesquisador1_id = target_pesquisador_id, pesquisador2_id = source_id[0]))
          db.commit()
        if num_rec_corals > 0:
          #excluindo possíveis recomendações
          cursor.execute("DELETE FROM recomenda WHERE pesquisador1_id = {pesquisador1_id} AND pesquisador2_id = {pesquisador2_id} AND metodo_id = 3".format(pesquisador1_id = target_pesquisador_id, pesquisador2_id = source_id[0]))
          db.commit()
        
  
