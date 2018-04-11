import socket
import struct
import binascii
from random import random
from math import floor
from time import sleep
import ssl


ssl_keyfile = "/home/pi/Desktop/keys/key.pem"
ssl_certfile = "/home/pi/Desktop/keys/cert.pem"

HOST = '10.0.0.216'
PORT = 9990
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
            connstream = ssl.wrap_socket(connection, 
                                            server_side=True,
                                            certfile = ssl_certfile,
                                            keyfile = ssl_keyfile,
                                            ssl_version = ssl.PROTOCOL_TLSv1
                                        )
            print "Received Connection"
            while True:
                sleep(0.5)
                header = ('tomsucks', 0, 10)
                header_packer = struct.Struct('! 8s I I')
                packed_header = header_packer.pack(*tuple(header))

                data_packer = struct.Struct('! 10I')
                packed_data = data_packer.pack(*tuple(data))
                connstream.sendall(packed_header + packed_data)
                data = generateRandomData()
                print data
        except socket.error, e:
            connstream.close()
        except IOError, e:
            if e.errno == errno.EPIPE:
                connstream.close()
                continue
        finally:
            connstream.close()

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

    return sock

if __name__ == '__main__':
    main()