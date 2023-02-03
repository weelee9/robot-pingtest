from pingtool import PingTool

class PingLibrary(object):
    def __init__(self):
        self.pingtool = PingTool()
        self.response = None

    def ping_address(self, address, num_packets):
        try:
            self.pingtool.ping(address, num_packets)
        except:
            raise Exception("Host unreachable.")

        self.response = self.pingtool.parse()

        return self.response