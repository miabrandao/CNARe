# coding=utf-8

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("UPDATE autor SET selecao = 1 WHERE EXISTS (SELECT pesquisador.id FROM pesquisador WHERE pesquisador.id = autor.pesquisador_id AND pesquisador.selecao = 1)")
db.commit()

cursor.execute("UPDATE pesquisador SET selecao = 0")
db.commit()
