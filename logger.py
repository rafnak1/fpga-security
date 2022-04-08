import datetime

def registrar(evento):
    with open("log.csv", "a") as f:
        f.write(str(datetime.datetime.now()) + "," + evento + "\n")

def abriu():
    print("Registrando abertura")
    registrar("abertura")

def alarme(fimES):
    print("Registrando acionamento do alarme, fimES =", fimES)
    registrar("alarme," + ("limite de tentativas" if fimES else "não foi o limite de tentativas"))

def userid(userid):
    print("Registrando tentativa de login")
    registrar("tentativa de login," + str(userid))

