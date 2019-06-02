import socket, select, string, sys
from chatapi import Chat

if __name__ == "__main__":
    host = "localhost"
    porta = int(sys.argv[1])
    server = Chat(host, porta, True)

    while True:
        conexao = server.getConnection()

        readable, writable, erro = select.select(server.getConnected(),[],[])

        for conexoes in readable:
            if conexoes == conexao:
                #nome, conn, addr = server.setConn(conexao)
                server.serverSetConnection(conexao)

            else:
                try:
                    recebido = conexoes.recv(4096)
                    if recebido == "privado\n" :
                        server.sendStatus("erro1", conexoes)

                    elif not recebido.strip() and recebido :
                        server.sendStatus("erro2", conexoes)

                    elif "privado;" in recebido:
                        sender = server.getSender(conexoes)
                        aux = recebido.split(";")
                        aux = aux[1].split(":")

                        if len(aux) != 2:
                            server.sendStatus("erro1", conexoes)
                        else:
                            receiver = aux[0]
                            msg = aux[1]
                            server.serverSendPrivateMessage(conexoes, sender, receiver,msg)

                    elif "sair\n" in recebido:
                        sender = server.getSender(conexoes)
                        server.disconnect(conexoes,sender)
                    else:
                        server.serverSendMessagetoAll(conexoes, recebido)

                except:
                    sender = server.getSender(conexoes)
                    server.disconnect(conexoes,sender)
                    continue
    conexao.close()
