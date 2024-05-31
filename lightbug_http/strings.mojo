from lightbug_http.io.bytes import Bytes

alias strSlash = String("/")._buffer
alias strHttp = String("http")._buffer
alias http = String("http")
alias strHttps = String("https")._buffer
alias https = String("https")
alias strHttp11 = String("HTTP/1.1")._buffer
alias strHttp10 = String("HTTP/1.0")._buffer

alias strMethodGet = "GET"

alias rChar = String("\r").as_bytes()
alias nChar = String("\n").as_bytes()

alias empty_string = Bytes(String("").as_bytes())

# Helper function to split a string into two lines by delimiter
fn next_line(s: String, delimiter: String = "\n") raises -> (String, String):
    var first_newline = s.find(delimiter)
    if first_newline == -1:
        return (s, String())
    var before_newline = s[0:first_newline]
    var after_newline = s[first_newline + 1 :]
    return (before_newline, after_newline)

@value
struct NetworkType:
    var value: String

    alias empty = NetworkType("")
    alias tcp = NetworkType("tcp")
    alias tcp4 = NetworkType("tcp4")
    alias tcp6 = NetworkType("tcp6")
    alias udp = NetworkType("udp")
    alias udp4 = NetworkType("udp4")
    alias udp6 = NetworkType("udp6")
    alias ip = NetworkType("ip")
    alias ip4 = NetworkType("ip4")
    alias ip6 = NetworkType("ip6")
    alias unix = NetworkType("unix")

@value
struct ConnType:
    var value: String

    alias empty = ConnType("")
    alias http = ConnType("http")
    alias websocket = ConnType("websocket")

@value
struct RequestMethod:
    var value: String

    alias get = RequestMethod("GET")
    alias post = RequestMethod("POST")
    alias put = RequestMethod("PUT")
    alias delete = RequestMethod("DELETE")
    alias head = RequestMethod("HEAD")
    alias patch = RequestMethod("PATCH")
    alias options = RequestMethod("OPTIONS")

@value
struct CharSet:
    var value: String

    alias utf8 = CharSet("utf-8")

@value
struct MediaType:
    var value: String

    alias empty = MediaType("")
    alias plain = MediaType("text/plain")
    alias json = MediaType("application/json")

@value
struct Message:
    var type: String

    alias empty = Message("")
    alias http_start = Message("http.response.start")
