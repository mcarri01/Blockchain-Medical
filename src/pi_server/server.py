import socket
import struct
import binascii
from random import random
from math import floor
from time import sleep
import ssl

HOST = '10.0.0.216'
PORT = 9994
def main():
    global TOTAL_SENT

    # initialize the socket
    sock = init_socket()

    if sock == None:
        return

    # packing data for a chart
    #data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    data = generateRandomData()
    while True:
        # wait for connection
        try:
            connection, client_address = sock.accept()
            print "Received Connection"
            while True:
                sleep(0.5)
                header = ('tomsucks', 0, 10)
                header_packer = struct.Struct('! 8s I I')
                packed_header = header_packer.pack(*tuple(header))

                data_packer = struct.Struct('! 10I')
                packed_data = data_packer.pack(*tuple(data))
                connection.sendall(packed_header + packed_data)
                #data = map(lambda x: x + 1, data)
                data = generateRandomData()
                print data
                #connection.sendall(str(int(floor(random() * 10))))
        except KeyboardInterrupt:
            connection.close()
        finally:
            connection.close()

def generateRandomData():
    ret = []
    for i in range(10):
        ret.append(int(floor(random() * 10)))
    return ret

def init_socket():
    # initialize socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_address = (HOST, PORT)
    
    # handle if address is in use
    try:
        print 'starting on %s:%s' % server_address
        sock.bind(server_address)
    except:
        print "address already in use, init failed"
        return None

    sock.listen(1)
    #wrappedSocket = ssl.wrap_socket(sock, ssl_version=ssl.PROTOCOL_TLSv1, ciphers="ADH-AES256-SHA")

    #return wrappedSocket
    return sock

if __name__ == '__main__':
    main()