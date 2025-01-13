from lightbug_http.net import listen_udp, UDPAddr
from utils import StringSlice


fn main() raises:
    var listener = listen_udp("127.0.0.1", 12000)

    while True:
        # Accept incoming messages
        response, host, port = listener.read_from(16)
        var message = String(StringSlice(unsafe_from_utf8=response))
        print("Message received:", message)

        # Response with the same message in uppercase
        _ = listener.write_to(message.as_bytes(), host, port)