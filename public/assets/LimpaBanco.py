# coding=utf-8

import MySQLdb

db = MySQLdb.connect(host="localhost", user="root",
passwd="53221554", db="cnare_development")

cursor = db.cursor()

cursor.execute("UPDATE autor SET selecao = 0")
db.commit()

cursor.execute("DROP TABLE IF EXISTS areaPesquisa")
db.commit()

cursor.execute("DROP TABLE IF EXISTS areaPesquisaPesquisador")
db.commit()

cursor.execute("TRUNCATE TABLE autor_publicacao_instituicao")
db.commit()

cursor.execute("DROP VIEW IF EXISTS autor_publicacao_instituicao_aux")
db.commit()

cursor.execute("DROP VIEW IF EXISTS coauthorship_network")
db.commit()

cursor.execute("DROP TABLE IF EXISTS colaboracao_gabarito")
db.commit()

cursor.execute("DROP TABLE IF EXISTS colaboracao_gabarito_itensificacao")
db.commit()

cursor.execute("DROP TABLE IF EXISTS cooperacao_agrupada_instituicao")
db.commit()

cursor.execute("DROP TABLE IF EXISTS importancia_autor_localizacao")
db.commit()

cursor.execute("DROP TABLE IF EXISTS importancia_autor_tema")
db.commit()

cursor.execute("TRUNCATE TABLE publicacao_aux")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomendacao")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomendacao_local")
db.commit()

cursor.execute("DROP VIEW IF EXISTS recomenda_itensificar_colaboracao")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomenda_itensificar_colaboracao_deduplicada")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomenda_itensificar_colaboracao_loc_deduplicada")
db.commit()

cursor.execute("DROP VIEW IF EXISTS recomenda_nao_colaboracao")
db.commit()

cursor.execute("DROP VIEW IF EXISTS recomenda_nova_colaboracao")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomenda_nova_colaboracao_deduplicada")
db.commit()


cursor.execute("DROP TABLE IF EXISTS recomenda_nova_colaboracao_loc2_deduplicada")
db.commit()

cursor.execute("DROP VIEW IF EXISTS recomenda_nova_colaboracao_loc3")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomenda_nova_colaboracao_loc3_deduplicada")
db.commit()

cursor.execute("DROP TABLE IF EXISTS recomenda_nova_colaboracao_loc_deduplicada")
db.commit()

cursor.execute("DROP VIEW IF EXISTS viewGrafoGeral")
db.commit()
