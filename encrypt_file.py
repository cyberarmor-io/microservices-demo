from Crypto.Cipher import AES
import sys, os
import binascii

with open(sys.argv[2],'rb') as pf:
    with open(sys.argv[3],'wb') as cf:
        size = os.path.getsize(sys.argv[2])
        remainder = size % 16
        cipher = AES.new(binascii.unhexlify(sys.argv[1]))
        plaintext = pf.read()
        ciphertext = cipher.encrypt(plaintext[:-remainder])
        cf.write(ciphertext+plaintext[-remainder:])

    



