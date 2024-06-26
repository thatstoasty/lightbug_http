from lightbug_http.client import Client
from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.header import ResponseHeader
from lightbug_http.sys.net import create_connection
from lightbug_http.io.bytes import Bytes
from lightbug_http.strings import next_line
from external.libc import (
    c_int,
    AF_INET,
    SOCK_STREAM,
    socket,
    connect,
    send,
    recv,
    close,
)


struct MojoClient(Client):
    var fd: c_int
    var host: StringLiteral
    var port: Int
    var name: String

    fn __init__(inout self) raises:
        self.fd = socket(AF_INET, SOCK_STREAM, 0)
        self.host = "127.0.0.1"
        self.port = 8888
        self.name = "lightbug_http_client"

    fn __init__(inout self, host: StringLiteral, port: Int) raises:
        self.fd = socket(AF_INET, SOCK_STREAM, 0)
        self.host = host
        self.port = port
        self.name = "lightbug_http_client"

    fn do(self, req: HTTPRequest) raises -> HTTPResponse:
        """
        The `do` method is responsible for sending an HTTP request to a server and receiving the corresponding response.

        It performs the following steps:
        1. Creates a connection to the server specified in the request.
        2. Sends the request body using the connection.
        3. Receives the response from the server.
        4. Closes the connection.
        5. Returns the received response as an `HTTPResponse` object.

        Note: The code assumes that the `HTTPRequest` object passed as an argument has a valid URI with a host and port specified.

        Parameters
        ----------
        req : HTTPRequest :
            An `HTTPRequest` object representing the request to be sent.

        Returns
        -------
        HTTPResponse :
            The received response.

        Raises
        ------
        Error :
            If there is a failure in sending or receiving the message.
        """
        var uri = req.uri()
        try:
            _ = uri.parse()
        except e:
            print("error parsing uri: " + e.__str__())

        var host = String(uri.host())

        if host == "":
            raise Error("URI is nil")
        var is_tls = False

        if uri.is_https():
            is_tls = True

        var host_str: String
        var port: Int

        if host.__contains__(":"):
            var host_port = host.split(":")
            host_str = host_port[0]
            port = atol(host_port[1])
        else:
            host_str = host
            if is_tls:
                port = 443
            else:
                port = 80

        var conn = create_connection(self.fd, host_str, port)

        var req_encoded = encode(req, uri)
        var bytes_sent = conn.write(req_encoded)
        if bytes_sent == -1:
            raise Error("Failed to send message")

        var new_buf = Bytes()

        var bytes_recv = conn.read(new_buf)
        if bytes_recv == 0:
            conn.close()
        
        var response_first_line_headers_and_body = next_line(new_buf, "\r\n\r\n")
        var response_first_line_headers = response_first_line_headers_and_body.first_line
        var response_body = response_first_line_headers_and_body.rest

        var response_first_line_and_headers = next_line(response_first_line_headers, "\r\n")
        var response_first_line = response_first_line_and_headers.first_line
        var response_headers = response_first_line_and_headers.rest

        # Ugly hack for now in case the default buffer is too large and we read additional responses from the server
        var newline_in_body = response_body.find("\r\n")
        if newline_in_body != -1:
            response_body = response_body[:newline_in_body]

        var header = ResponseHeader(response_headers._buffer)

        try:
            header.parse(response_first_line)
        except e:
            conn.close()
            raise Error("Failed to parse response header: " + e.__str__())
        
        var total_recv = bytes_recv

        while header.content_length() > total_recv:
            if header.content_length() != 0 and header.content_length() != -2:
                var remaining_body = Bytes()
                var read_len = conn.read(remaining_body)
                response_body += remaining_body
                total_recv += read_len

        conn.close()

        return HTTPResponse(header, response_body._buffer)
