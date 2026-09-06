import sys
import pylzma
import struct
with open(sys.argv[1], 'rb') as f:
    data = f.read()
if data[:3] == b'ZWS':
    uncompressed_len = struct.unpack('<I', data[4:8])[0]
    out = b'FWS' + data[3:8] + pylzma.decompress(data[12:])
    with open(sys.argv[2], 'wb') as f:
        f.write(out)
elif data[:3] == b'CWS':
    import zlib
    out = b'FWS' + data[3:8] + zlib.decompress(data[8:])
    with open(sys.argv[2], 'wb') as f:
        f.write(out)
