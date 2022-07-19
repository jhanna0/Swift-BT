import asyncio, time, math
from bleak import BleakScanner
from bleak import BleakClient
import json
import os.path

class Bluetooth():
    def __init__(self, fp, name='Arduino', char='19B10001-E8F2-537E-4F6C-D104768A1214'):
        self.fp = fp
        self.name = name
        self.char = char
        self.address = ''
        self.client = ''
        self.data = ''
        self.proc = Data(fp)

    def write(self, msg):
        with open(os.path.join(self.fp, 'data.txt'), 'w') as f:
            f.write(json.dumps({"status": str(msg)}))

    async def connect(self):
        self.write("Scanning for compatible wearables...")
        devices = await BleakScanner.discover()
        d = [x for x in devices if self.name in x.name]

        if len(d) == 1:
            self.write("Wearable found...")
            time.sleep(0.5)
            self.write("connecting: {}...".format(str(d[0]).split('-')[0]))
            self.address = d[0].address
            await self.get_data()

        if len(d) != 1:
            self.write("No compatible wearable found")

    async def get_data(self):
        async with BleakClient(self.address) as self.client:
            while True: # get rid of this loop
                time.sleep(0.2)
                data = await self.client.read_gatt_char(self.char)
                self.data = data.decode('utf_8')
                self.proc.main(self.data)

    async def main(self):
        await self.connect()

    async def return_data(self):
        return self.data


class Data():
    def __init__(self, fp):
        self.data = ''
        self.fp = fp

    def parse_data(self):
        self.data = self.data.split("~")
        self.data = {'x': float(self.data[0]), 'y': float(self.data[1]), 'z': float(self.data[2])}

    def calc(self):
        self.data['roll'] = math.atan2(self.data['y'] , self.data['z']) * 57.3
        self.data['pitch'] = math.atan2(-1 * self.data['x'] , math.sqrt((self.data['y'] * self.data['y']) + (self.data['z'] * self.data['z']))) * 57.3
        self.data['roll'] = float("{:.2f}".format(self.data['roll']))
        self.data['pitch'] = float("{:.2f}".format(self.data['pitch']))

    def write(self):
        self.data['status'] = "Device Connected"
        with open(os.path.join(self.fp, 'data.txt'), 'w') as f:
            f.write(json.dumps(self.data))

    def print_data(self):
        return self.data

    def main(self, data):
        self.data = data
        self.parse_data()
        self.calc()
        self.write()

def main(fp):
    bte = Bluetooth(fp)
    asyncio.run(bte.main())
