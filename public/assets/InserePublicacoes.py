# coding=utf-8

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("SELECT * FROM  `publicacao_aux`")

numrows = int(cursor.rowcount)

for publicacao in cursor.fetchall():
  num_publicacoes = cursor.execute("SELECT * FROM publicacao WHERE titulo = '{titulo_publicacao}'".format(titulo_publicacao = publicacao[1]))
  #verificando se a publicacao já existe...
  if num_publicacoes == 0:
    num_temas = cursor.execute("SELECT * FROM tema WHERE nome = '{nome_tema}'".format(nome_tema = publicacao[3]))
    #verificando se o tema já existe...
    if num_temas == 0:
      #inserindo tema...
      cursor.execute("INSERT INTO tema (nome) VALUES ('{nome_tema}')".format(nome_tema = publicacao[3]))
      db.commit()
      cursor.execute("SELECT MAX(id) FROM tema")
      for id_tema in cursor.fetchall():
        #inserindo publicacao(caso um novo tema tenha sido inserido)... 
        cursor.execute("INSERT INTO publicacao (titulo, data_publicacao, tema_id, dsc_titulo) VALUES ('{titulo_publicacao}', {data_publicacao}, {t_id}, {local})".format(titulo_publicacao = publicacao[1], data_publicacao = publicacao[2], t_id = id_tema[0], local = publicacao[5]))
        db.commit()
    else:
      #buscando o id do tema...
      cursor.execute("SELECT id FROM tema WHERE nome = '{nome_tema}'".format(nome_tema = publicacao[3]))
      for id_tema in cursor.fetchall():
        #inserindo publicacao...
        cursor.execute("INSERT INTO publicacao (titulo, data_publicacao, tema_id, dsc_titulo) VALUES ('{titulo_publicacao}', '{data_publicacao}', {t_id}, '{local}')".format(titulo_publicacao = publicacao[1], data_publicacao = publicacao[2], t_id = id_tema[0], local = publicacao[5]))
        db.commit()
    #buscando id da publicacao inserida...
    cursor.execute("SELECT MAX(id) FROM publicacao")
    for id_pub in cursor.fetchall():
      #atualizando publicação temporária...
      cursor.execute("UPDATE publicacao_aux SET id = {p_id} WHERE title = '{titulo_publicacao}'".format(p_id = id_pub[0], titulo_publicacao = publicacao[1]))
      db.commit()
      #encontrando coautores...
      nomes = publicacao[4].split('/')
      for nome in nomes:
        #buscando o id do autor
        cursor.execute("SELECT id FROM pesquisador where nome = {name}".format(name = "\""+nome+"\""))
        for id_pesquisador in cursor.fetchall():
          cursor.execute("SELECT id FROM autor WHERE pesquisador_id = {p_id}".format(p_id = id_pesquisador[0]))
          for id_autor in cursor.fetchall():
            #inserindo dados na tabela autoria_autor_publicacao
            cursor.execute("INSERT INTO autoria_autor_publicacao (autor_id, publicacao_id) VALUES ({a_id}, {p_id})".format(a_id = id_autor[0], p_id = id_pub[0]))
            db.commit()
  else:
    #buscando id da publicacao...
    cursor.execute("SELECT id FROM publicacao WHERE titulo = '{titulo_publicacao}'".format(titulo_publicacao = publicacao[1]))
    for id_pub in cursor.fetchall():
      #atualizando publicação temporária...
      cursor.execute("UPDATE publicacao_aux SET id = {p_id} WHERE title = '{titulo_publicacao}'".format(p_id = id_pub[0], titulo_publicacao = publicacao[1]))
      db.commit()
      #encontrando coautores...
      nomes = publicacao[4].split('/')
      for nome in nomes:
        #buscando o id do autor
        cursor.execute("SELECT id FROM pesquisador where nome = {name}".format(name = "\""+nome+"\""))
        for id_pesquisador in cursor.fetchall():
          cursor.execute("SELECT id FROM autor WHERE pesquisador_id = {p_id}".format(p_id = id_pesquisador[0]))
          for id_autor in cursor.fetchall():
            #verificando se a relação autor_publicação já está presente no banco...
            num_autoria = cursor.execute("SELECT * FROM autoria_autor_publicacao WHERE autor_id = {a_id} AND publicacao_id = {p_id}".format(a_id = id_autor[0], p_id = id_pub[0]))
            if num_autoria == 0:
              #inserindo dados na tabela autoria_autor_publicacao
              cursor.execute("INSERT INTO autoria_autor_publicacao (autor_id, publicacao_id) VALUES ({a_id}, {p_id})".format(a_id = id_autor[0], p_id = id_pub[0]))
              db.commit()
