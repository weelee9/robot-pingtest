from pingtool import PingTool

class PingLibrary(object):
    def __init__(self):
        self.pingtool = PingTool()

    def ping_address(self, address, num_packets):
        try:
            self.pingtool.ping(address, num_packets)
        except:
            raise Exception(f"Host {address} unreachable.")

        self.pingtool.parse()

        return self.pingtool.get_response_dict()

    def write_output_to_json(self, path):
        self.pingtool.write_output_to_json(path)

    def append_response_to_output(self):
        self.pingtool.append_response_to_output()