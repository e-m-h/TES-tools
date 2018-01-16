import binascii
import re

#modifying SAVETREE.DAT
#00009b20
#Offset is 9B29

def changeDistance():
	with open('SAVETREE.DAT', 'rb') as f, open('newsavetree', 'wb') as fout:
		hexdata = binascii.hexlify(f.read())
		stuff = (hexdata.decode())
		stuff = re.sub(r'7f7f0080', 'ff7f0080', stuff)
		stuff = stuff.encode()
#		print(stuff)
		fout.write(
			binascii.unhexlify(stuff)
		)

changeDistance()
