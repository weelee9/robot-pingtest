import subprocess
import re

class PingTool(object):
    response = ''

    def ping(self, address, num_packets):
        self.response = subprocess.check_output(
            ['ping', address, '/n', num_packets],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )

    def parse(self):
        self.response = self.response.split('\n')
        packet_line, ping_line = -1, -1

        for index, line in enumerate(self.response):
            if 'Sent = ' in line:
                packet_line = index

            if 'Minimum = ' in line:
                ping_line = index

        packet_stats = re.findall(r'\d+', self.response[packet_line])
        ping_stats = re.findall(r'\d+', self.response[ping_line])

        response_dict = {
            'sent' : packet_stats[0],
            'rcvd' : packet_stats[1],
            'lost' : packet_stats[2],
            'loss' : packet_stats[3],
            'min_ping' : ping_stats[0],
            'max_ping' : ping_stats[1],
            'avg_ping' : ping_stats[2]
        }

        return response_dict