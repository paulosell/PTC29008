
import socket, select, string, sys

class Chat:
    def __init__(self, host, port, server):
        self.port = port
        self.host = host
        self.connection =  socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server = server
        self.connected = []
        self.userslist = {}
        self.users = {}

        if (self.server == True):
            self.connection.bind((host,port))
            self.connection.listen(100)
            self.connected.append(self.connection)
            print "Servidor esta online"
        else:
            try:
                self.connection.connect((host,port))

            except:
                print "Verifique as credenciais do servidor (IP e porta)"
                sys.exit()



    def getConnected(self): # server
        return self.connected

    def setUser(self, user): # cliente
        self.usuario = user

    def serverSetConnection(self, sockobj): # server
        conn, addr = sockobj.accept()
        msg = conn.recv(4096)
        name = ""
        if msg == "inicio":
            self.sendStatus("ok",  conn)
            name = conn.recv(4096)
            self.connected.append(conn)
            self.userslist[addr,conn] = ""
            self.users[conn] = ""
            if name not in self.userslist.values():
                self.sendStatus("ok", conn)
                self.userslist[addr,conn] = name
                self.users[conn] = name
                print "Cliente (%s, %s) conectado" % addr," [",self.userslist[addr,conn],"]"
            else:
                self.sendStatus("disconnect", conn)
                del self.userslist[addr,conn]
                del self.users[conn]
                self.connected.remove(conn)
                self.closeConnection(conn)
        else:
            self.sendStatus("disconnect",  conn)
            self.closeConnection(conn)


    def clientSetConnection(self): # cliente
        inicio = "inicio"
        self.connection.send(inicio)
        status = self.connection.recv(4096)
        if not status == "ok":
            print "Conexao com o servidor nao foi aceita"
            return False
        else:
            self.connection.send(self.usuario)
            status = self.connection.recv(4096)
            if not status == "ok":
                print "Nome de usuario ja existente"
                return False
            else:
                return True

    def getConnection(self): # cliente e servidor
        return self.connection

    def clientSendMessage(self, msg): # cliente
        self.connection.send(msg)



    def receiveMessage(self): # cliente
        return self.connection.recv(4096)

    def sendStatus(self, msg, sockobj): # server
        status = msg
        sockobj.send(status)


    def closeConnection(self, sockobj): # server ?
        sockobj.close()

    def getSender(self, sockobj):
        for users in self.users.items():
            if users[0] == sockobj:
                return users[1]

    def disconnect(self, sockobj, sender):
        msg = "Usuario " + self.users[sockobj] + " desconectou\n"
        print msg
        for names in self.userslist.items():
            if names[1] == sender:

                del self.userslist[names[0]]

        for names in self.users.items():
            if names[1] == sender:
                del self.users[sockobj]

        self.connected.remove(sockobj)


        for conexoes in self.connected:
            if conexoes != self.connection and conexoes != sockobj:
                try:
                    conexoes.send(msg)
                except:
                    conexoes.close()
                    self.connected.remove(conexoes)



    def serverSendPrivateMessage(self,sockobj,sender, receiver, msg):
        flag = 0;
        for names in self.users.items():
            if names[1] == receiver:
                names[0].send(self.users[sockobj] + ": " + msg)
                self.sendStatus("ok", sockobj)
                flag = 1

        if flag == 0:
            self.sendStatus("erro3", sockobj)

    def serverSendMessagetoAll(self, sockobj, msg): # server
        for conexoes in self.connected:
            if conexoes != self.connection and conexoes != sockobj:
                try:
                    conexoes.send((self.users[sockobj]+": "+msg))
                except:
                    conexoes.close()
                    self.connected.remove(conexoes)

        self.sendStatus("ok", sockobj)
