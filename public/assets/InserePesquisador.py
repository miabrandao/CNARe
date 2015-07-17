# coding=utf-8

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("SELECT * FROM  `pesquisador_aux`")

numrows = int(cursor.rowcount)


for pesquisador in cursor.fetchall():
  num = cursor.execute("SELECT * FROM pesquisador WHERE nome = '{nome_pesquisador}'".format(nome_pesquisador = pesquisador[1]))
  #verificando se o pesquisador já existe...
  if num == 0:
    #inserindo pesquisador...
    if pesquisador[4] <> None:
      cursor.execute("INSERT INTO pesquisador (nome, area, instituicao, selecao) VALUES ('{nome_pesquisador}', '{area_pesquisador}', '{instituicao_pesquisador}', 0)".format(nome_pesquisador = pesquisador[1], area_pesquisador = pesquisador[2], instituicao_pesquisador = pesquisador[4])) 
      db.commit()
    else:
      cursor.execute("INSERT INTO pesquisador (nome, area, instituicao, selecao) VALUES ('{nome_pesquisador}', '{area_pesquisador}', '{instituicao_pesquisador}', 0)".format(nome_pesquisador = pesquisador[1], area_pesquisador = pesquisador[2], instituicao_pesquisador = pesquisador[3])) 
      db.commit()
    #inserindo pesquisador na tabela de nós...
    cursor.execute("INSERT INTO node (name) VALUES ('{nome_pesquisador}')".format(nome_pesquisador = pesquisador[1]))
    db.commit()
    #inserindo nome do pesquisador na lista de nomes sugestivos...
    cursor.execute("INSERT INTO search_suggestion (term, popularity) VALUES ('{nome_pesquisador}', 1)".format(nome_pesquisador = pesquisador[1].lower()))
    db.commit()
    cursor.execute("SELECT MAX(id) FROM pesquisador")
    #inserindo autor...
    for pesquisador_id in cursor.fetchall():
      cursor.execute("INSERT INTO autor (pesquisador_id) VALUES ({p_id})".format(p_id = pesquisador_id[0]))
      db.commit()
      #atualizando pesquisador temporário...
      cursor.execute("UPDATE pesquisador_aux set id = {p_id} WHERE name = '{nome_pesquisador}'".format(p_id = pesquisador_id[0], nome_pesquisador = pesquisador[1]))
      db.commit()
      num = cursor.execute("SELECT * FROM instituicao WHERE nome = '{instituicao_pesquisador}'".format(instituicao_pesquisador = pesquisador[3]))
      #verificando se a instituicao já existe...
      if num == 0:
        #inserindo a instituicao... 
        cursor.execute("INSERT INTO instituicao (nome, acronimo) VALUES ('{instituicao_pesquisador}', {acronimo})".format(instituicao_pesquisador = pesquisador[3], acronimo = pesquisador[4]))
        db.commit()
        cursor.execute("SELECT MAX(id) FROM instituicao")
        for instituicao_id in cursor.fetchall():
          #associando pesquisador a instituicao...
          cursor.execute("INSERT INTO associacao_pesquisador_instituicao (instituicao_id, pesquisador_id) VALUES ({i_id}, {p_id})".format(i_id = instituicao_id[0], p_id = pesquisador_id[0]))
          db.commit()
      else:
        #buscando id da instituicao...
        cursor.execute("SELECT id FROM instituicao WHERE nome = '{instituicao_pesquisador}'".format(instituicao_pesquisador = pesquisador[3]))
        #associando pesquisador instituicao...
        for instituicao_id in cursor.fetchall():
          cursor.execute("INSERT INTO associacao_pesquisador_instituicao (instituicao_id, pesquisador_id) VALUES ({i_id}, {p_id})".format(i_id = instituicao_id[0], p_id = pesquisador_id[0]))
          db.commit()    
  else:
    cursor.execute("SELECT id FROM pesquisador WHERE nome = '{nome_pesquisador}'".format(nome_pesquisador = pesquisador[1]))
    for pesquisador_id in cursor.fetchall():
      #atualizando pesquisador temporário...
      cursor.execute("UPDATE pesquisador_aux set id = {p_id} WHERE name = '{nome_pesquisador}'".format(p_id = pesquisador_id[0], nome_pesquisador = pesquisador[1]))
      db.commit()
