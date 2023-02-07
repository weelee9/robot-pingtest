from pingtool import PingTool

class PingLibrary(object):
    def __init__(self):
        self.pingtool = PingTool()

    def ping(self, address, num_packets, wait_time=1000):
        self.pingtool.ping(address, num_packets, wait_time)

    def get_json_response(self):
        self.pingtool.get_response_dict()

    # def write_output_to_json(self, path):
    #     self.pingtool.write_output_to_json(path)

    # def append_response_to_output(self):
    #     self.pingtool.append_response_to_output()