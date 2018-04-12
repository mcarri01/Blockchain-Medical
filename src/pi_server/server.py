import socket
import struct
import binascii
from random import random
from math import floor
from time import sleep
import ssl
#import Adafruit_GPIO.SPI as SPI
#import Adafruit_MCP3008

# Hardware SPI configuration:
SPI_PORT   = 0
SPI_DEVICE = 0
#mcp = Adafruit_MCP3008.MCP3008(spi=SPI.SpiDev(SPI_PORT, SPI_DEVICE))

ssl_keyfile = "/home/pi/Desktop/keys/key.pem"
ssl_certfile = "/home/pi/Desktop/keys/cert.pem"

HOST = '10.0.0.216'
PORT = 9999
def main():
    global TOTAL_SENT
    # initialize the socket
    sock = init_socket()
    if sock == None:
        return

    # packing data for a chart
    print('| {0:>4} | {1:>4} | {2:>4} | {3:>4} | {4:>4} | {5:>4} | {6:>4} | {7:>4} |'.format(*range(8)))
    print('-' * 57)
    #data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    #data = generateRandomData()
    while True:
        print("here1")
	# wait for connection
        try:
	    print("here2")
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
                values = [0]*10
                for i in range(8):
                    # The read_adc function will get the value of the specified channel (0-7).
                    #values[i] = mcp.read_adc(i)
		    values[i] = 1
                # Print the ADC values.
                values[8] = 0
                values[9] = 0
                print('| {0:>4} | {1:>4} | {2:>4} | {3:>4} | {4:>4} | {5:>4} | {6:>4} | {7:>4} |'.format(*values))
                header = ('forkpork1', 10)
                header_packer = struct.Struct('! 9s I')
                packed_header = header_packer.pack(*tuple(header))
                data_packer = struct.Struct('! 10I')
                packed_data = data_packer.pack(*tuple(values))
                connstream.sendall(packed_header + packed_data)
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

