#!/usr/bin/python3
# -*- coding: utf-8 -*- 



__author__ = "Paulo Sell e Maria Fernanda Tutui"

import sys
import layer

class FakeLayer(layer.Layer):
    '''
      Classe para receber dados do teclado e transmiti-los
    '''
    def __init__(self, fd, timeout):
        ''' fd: descritor de arquivos sys.stdin
            timeout: timeout: intervalo de tempo para interrupção interna
        '''
        self._top = None
        self._bottom = None
        self.timeout = timeout
        self.fd = sys.stdin
        self.base_timeout = timeout
        self.disable_timeout()
        self.enable()

    def handle_timeout(self):
        ''' Trata a interrupção interna devido ao timeout
        '''
        pass

    def receiveFromBottom(self, data):
        ''' Recebe um quadro da camada inferior
            data: bytearray representando o quadro recebido
        '''
        print(data.decode('ascii'))

    def handle(self):
        ''' Trata o evento de recebimento de bytes pelo teclado
        '''
        frame = sys.stdin.readline()
        frameToBeSent = bytearray()
        for i in range(len(frame) - 1):
            frameToBeSent.append(int.from_bytes(frame[i].encode('ascii'), 'big'))
        self.sendToLayer(frameToBeSent)

    def sendToLayer(self, data):
        ''' Envia o frame a ser transmitido para a camada inferior
            data: bytearray representando o frame a ser transmitido
        '''
        self._bottom.receiveFromTop(data)

    def notifyLayer(self, data):
        ''' Envia o frame recebido para a camada superior
            data: bytearray representando o frame a ser enviado
        '''
        pass

