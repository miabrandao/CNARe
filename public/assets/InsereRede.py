# coding=utf-8

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("SELECT * FROM  `rede_aux`")

numrows = int(cursor.rowcount)

for rede_inserida in cursor.fetchall():
  print rede_inserida[1]
  num_redes = cursor.execute("SELECT * FROM rede WHERE nome = '{nome_rede}'".format(nome_rede = rede_inserida[1]))
  #verificando se a rede já existe...
  if num_redes == 0:
    #inserindo rede...
    cursor.execute("INSERT INTO rede (nome) VALUES ('{nome_rede}')".format(nome_rede = rede_inserida[1]))
    db.commit()
    #buscando o id da rede inserida...
    cursor.execute("SELECT id FROM rede WHERE nome = '{nome_rede}'".format(nome_rede = rede_inserida[1]))
    for id_rede in cursor.fetchall():
      #buscando o id dos pesquisadores inseridos a rede...
      cursor.execute("SELECT * FROM  `pesquisador_aux`")
      for nome_pesquisador in cursor.fetchall():
        cursor.execute("SELECT id FROM pesquisador WHERE nome = '{p_nome}'".format(p_nome = nome_pesquisador[1]))
        for id_pesquisador in cursor.fetchall():
          #associando pesquisadores e rede inseridos...
          num_associacoes = cursor.execute("SELECT * FROM associacao_pesquisador_rede WHERE pesquisador_id = {p_id} AND rede_id = {r_id}".format(p_id = id_pesquisador[0], r_id = id_rede[0]))
          if num_associacoes == 0:
            #inserindo associacoes...
            cursor.execute("INSERT INTO associacao_pesquisador_rede (pesquisador_id, rede_id) VALUES ({p_id},  {r_id})".format(p_id = id_pesquisador[0], r_id = id_rede[0]))
            db.commit()
  else:
    #buscando o id da rede...
    cursor.execute("SELECT id FROM rede WHERE nome = '{nome_rede}'".format(nome_rede = rede_inserida[1]))
    for id_rede in cursor.fetchall():
      #buscando o id dos pesquisadores inseridos a rede...
      cursor.execute("SELECT * FROM  `pesquisador_aux`")
      for nome_pesquisador in cursor.fetchall():
        cursor.execute("SELECT id FROM pesquisador WHERE nome = '{p_nome}'".format(p_nome = nome_pesquisador[1]))
        for id_pesquisador in cursor.fetchall():
          #associando pesquisadores e rede inseridos...
          num_associacoes = cursor.execute("SELECT * FROM associacao_pesquisador_rede WHERE pesquisador_id = {p_id} AND rede_id = {r_id}".format(p_id = id_pesquisador[0], r_id = id_rede[0]))
          if num_associacoes == 0:
            #inserindo associacoes...
            cursor.execute("INSERT INTO associacao_pesquisador_rede (pesquisador_id, rede_id) VALUES ({p_id},  {r_id})".format(p_id = id_pesquisador[0], r_id = id_rede[0]))
            db.commit()
  
