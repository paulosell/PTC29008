import socket, select, string, sys
from chatapi import Chat

def chat():
    you = '\r'+"Voce: "
    sys.stdout.write(you)
    sys.stdout.flush()

def main():
    host = "localhost"
    porta = int(sys.argv[1])
    nome = ""
    nome = raw_input("Digite nome de usuario:\n")

    while (nome is None) or (str(nome).strip() == ""):
        print "!!! Voce nao digitou o nome de usuario !!!\n"
        nome = raw_input("Digite o nome de usuario:\n")


    cliente = Chat(host,porta,False)
    cliente.setUser(nome)
    if cliente.clientSetConnection():
        conexao = cliente.getConnection()
        print "Bem vindo a sala de conversa"
        chat()
    else:
        sys.exit()

    while True:

        conectados = [sys.stdin, conexao]
        readable, writable, erro = select.select(conectados, [], [])

        for conexoes in readable:
            if conexoes == conexao:
                try:
                    dados = cliente.receiveMessage()
                    if not dados:
                        print '\r'+" --- O servidor foi desligado. Encerrando a sessao --- "
                        sys.exit()

                    else:
                        sys.stdout.write('\r'+dados)
                        sys.stdout.flush()
                        chat()
                except:
                    sys.exit()

            else:
                msg = sys.stdin.readline()
                if msg == "sair\n":
                    cliente.clientSendMessage(msg)
                    cliente.closeConnection(conexao)
                    sys.exit()
                else:
                    cliente.clientSendMessage(msg)
                    status = cliente.receiveMessage()
                    if status == "ok":
                        chat()
                    elif status == "erro1" :
                        print '\r'+">>> Para mandar mensagem privada: 'privado;usuario:mensagem' <<<"
                        chat()
                    elif status == "erro2" :
                        print '\r'+">>> Voce nao digitou nenhuma mensagem <<< "
                        chat()
                    elif status == "erro3" :
                        print '\r'+">>> O usuario escolhido nao esta conectado <<<"
                        chat()



if __name__ == "__main__":
    main()
