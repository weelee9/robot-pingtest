import subprocess
import re
import json

class PingTool(object):
    def __init__(self):
        self.address = ''
        self.raw_response = ''
        self.response_dict = {}
        self.output = []

    def ping(self, address, num_packets):
        self.address = address

        self.response = subprocess.check_output(
            ['ping', address, '-c', str(num_packets)],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )

    def parse(self):
        self.response = self.response.split('\n')
        packet_line, ping_line = -1, -1

        for index, line in enumerate(self.response):
            if 'transmitted' in line:
                packet_line = index

            if 'round-trip' in line:
                ping_line = index

        packet_stats = re.findall(r'[-+]?(?:\d*\.*\d+)', self.response[packet_line])
        ping_stats = re.findall(r'[-+]?(?:\d*\.*\d+)', self.response[ping_line])

        self.response_dict = {
            'address' : self.address,
            'sent' : packet_stats[0],
            'rcvd' : packet_stats[1],
            'loss' : packet_stats[2],
            'min_ping' : ping_stats[0],
            'avg_ping' : ping_stats[1],
            'max_ping' : ping_stats[2]
        }

    def get_response_dict(self):
        return self.response_dict

    def append_response_to_output(self):
        self.output.append(self.response_dict)

    def write_output_to_json(self, path):
        with open(path, 'w') as output:
            json.dump(self.output, output, indent=4)
            output.close()