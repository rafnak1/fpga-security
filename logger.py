import datetime

def registrar(evento):
    with open("log.csv", "a") as f:
        f.write(str(datetime.datetime.now()) + "," + evento + "\n")

def abriu():
    print("Registrando abertura")
    registrar("abertura")

def alarme():
    print("Registrando acionamento do alarme")
    registrar("alarme")

def userid(userid):
    print("Registrando tentativa de login")
    registrar("tentativa de login," + userid)

