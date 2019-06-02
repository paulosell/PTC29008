import socket 
import poller
import response
import random

class COAP(poller.Callback):
    versionAndTypeAndTKL = 0x51
    codeGET = 0x01
    optionURIPATH = 0xB0
    end = 0xFF
    idle = 0
    wait = 1
    wait2 = 2

    def __init__(self, ip):
        self.p = poller.Poller()
        self.ip = ip
        self.query = bytearray()
        self.servidor = (ip,5683)
        self.sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        self.sock.bind(('::', 0))
        self.fd = self.sock
        self.enable()
        self.disable_timeout()
        self.base_timeout = 10
        self.timeout = 10
        self.state = self.idle
        self.f = False
        self.response = None
        
    def handle_fsm(self, frame):
        if(self.state == self.idle):
            self.sock.sendto(self.query, self.servidor)
            self.state = self.wait
        elif (self.state == self.wait):
            if(((frame[0] >> 4) == 6) and frame[1] == 0): 
                self.state = self.wait2
            else:
                if ((frame[0] >> 4) == 6):
                    if(frame[1] == 0x45):
                        type = (frame[0] << 2)
                        type = type >> 6
                        tkllen = frame[0] & 0x0F
                        code = frame[1]
                        mid = frame[2:4]
                        token = frame[4:(4+tkllen)]
                        payload = frame[5+tkllen:]
                        self.response = response.Response(type, tkllen, code, mid, token, payload)                        
                        self.disable()
                        self.f = True
                        
                elif((frame[0] >> 4) == 4):
                    if(frame[1] == 0x45):                        
                        type = (frame[0] << 2)
                        type = type >> 7
                        tkllen = frame[0] & 0x0F
                        code = frame[1]
                        mid = frame[2:4]
                        token = frame[4:(4+tkllen)]
                        payload = frame[5+tkllen:]
                        self.response = response.Response(type, tkllen, code, mid, token, payload) 
                        self.sendACK(frame[2], frame[3])                        
                        self.disable()     
                        self.f = True        
                            
        elif (self.state == self.wait2):         
            if ((frame[0] >> 4) == 6):
                if(frame[1] == 0x45):
                    type = (frame[0] << 2)
                    type = type >> 6
                    tkllen = frame[0] & 0x0F
                    code = frame[1]
                    mid = frame[2:4]
                    token = frame[4:(4+tkllen)]
                    payload = frame[5+tkllen:]
                    self.response = response.Response(type, tkllen, code, mid, token, payload)                        
                    self.disable()
                    self.f = True
                        
            elif((frame[0] >> 4) == 4):
                if(frame[1] == 0x45):                        
                    type = (frame[0] << 2)
                    type = type >> 7
                    tkllen = frame[0] & 0x0F
                    code = frame[1]
                    mid = frame[2:4]
                    token = frame[4:(4+tkllen)]
                    payload = frame[5+tkllen:]
                    self.response = response.Response(type, tkllen, code, mid, token, payload) 
                    self.sendACK(frame[2], frame[3])                        
                    self.disable()     
                    self.f = True         

    def sendACK(self, id1, id2):
        toBeSent = bytearray()
        toBeSent.append(0x60)
        toBeSent.append(0x00)
        toBeSent.append(id1)
        toBeSent.append(id2)
        self.sock.sendto(toBeSent,self.servidor)
    
    def handle(self):
        self.handle_fsm(self.sock.recv(4096))
        

    def handle_timeout(self):
        pass
    
    def do_get(self, uri):
            uris = uri.split("/")
            firstByteID = random.randint(0,255)
            secondByteID = random.randint(0,255)
            token = random.randint(0,255)
            self.query.append(self.versionAndTypeAndTKL)
            self.query.append(self.codeGET)
            self.query.append(firstByteID)
            self.query.append(secondByteID)
            self.query.append(token)
            for i in range (len(uris)):
                if (i == 0):
                    self.query.append((self.optionURIPATH) | (len(uris[i]) << 0))
                else:
                    self.query.append(0 | (len(uris[i]) << 0))
                for j in range (len(uris[i])):
                    self.query.append(ord(uris[i][j]))      
            self.query.append(self.end)
            print(self.query)        
            self.handle_fsm(self.query) 
            self.p.adiciona(self)
            self.p.despache()    
            return self.response

            
        

    def do_put(self, url, payload=None):
        pass
    
    def do_post(self, url, payload=None):
        pass
    
    def do_delete(self, url, payload=None):
        pass