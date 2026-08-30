import zlib
import struct

with open('loader/Mobile.swf', 'rb') as f:
    data = f.read()

sig = data[:3]
version = data[3]
size = struct.unpack('<I', data[4:8])[0]

if sig == b'CWS':
    payload = zlib.decompress(data[8:])
elif sig == b'FWS':
    payload = data[8:]
else:
    raise ValueError("Not a supported SWF")

# Perform replacements
replacements = [
    (b'https://api.github.com/repos/anthony-hyo/aqw-mobile/releases/latest', b'https://api.github.com/repos/JonasAlv/aqw-mobile/releases/latest?a='),
    (b'https://github.com/anthony-hyo/aqw-mobile/issues', b'https://github.com/JonasAlv/aqw-mobile/issues?a='),
    (b'https://github.com/anthony-hyo/aqw-mobile/releases/latest', b'https://github.com/JonasAlv/aqw-mobile/releases/latest?a=')
]

new_payload = payload
for old, new in replacements:
    if len(old) != len(new):
        print(f"Length mismatch: {len(old)} vs {len(new)} for {old}")
    count = new_payload.count(old)
    print(f"Found {count} occurrences of {old}")
    new_payload = new_payload.replace(old, new)

if len(new_payload) != len(payload):
    print("FATAL ERROR: Payload length changed!")
    exit(1)

if sig == b'CWS':
    new_data = data[:8] + zlib.compress(new_payload)
else:
    new_data = data[:8] + new_payload

with open('loader/Mobile.swf', 'wb') as f:
    f.write(new_data)
print("Saved loader/Mobile.swf")
