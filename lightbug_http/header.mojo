from collections import Dict
from lightbug_http.io.bytes import Bytes, Byte
from lightbug_http.strings import BytesConstant
from lightbug_http.utils import ByteReader, ByteWriter, is_newline, is_space
from lightbug_http.strings import rChar, nChar, lineBreak, to_string


struct HeaderKey:
    # TODO: Fill in more of these
    alias CONNECTION = "connection"
    alias CONTENT_TYPE = "content-type"
    alias CONTENT_LENGTH = "content-length"
    alias CONTENT_ENCODING = "content-encoding"
    alias TRANSFER_ENCODING = "transfer-encoding"
    alias DATE = "date"
    alias LOCATION = "location"
    alias HOST = "host"
    alias SERVER = "server"
    alias SET_COOKIE = "set-cookie"
    alias COOKIE = "cookie"


@value
struct Header:
    var key: String
    var value: String


@always_inline
fn write_header[T: Writer](mut writer: T, key: String, value: String):
    writer.write(key + ": ", value, lineBreak)


@always_inline
fn write_header(mut writer: ByteWriter, key: String, mut value: String):
    var k = key + ": "
    writer.write(k)
    writer.write(value)
    writer.write(lineBreak)


@value
struct Headers(Writable, Stringable):
    """Represents the header key/values in an http request/response.

    Header keys are normalized to lowercase
    """

    var _inner: Dict[String, String]

    fn __init__(out self):
        self._inner = Dict[String, String]()

    fn __init__(out self, owned *headers: Header):
        self._inner = Dict[String, String]()
        for header in headers:
            self[header[].key.lower()] = header[].value

    @always_inline
    fn empty(self) -> Bool:
        return len(self._inner) == 0

    @always_inline
    fn __contains__(self, key: String) -> Bool:
        return key.lower() in self._inner

    @always_inline
    fn __getitem__(self, key: String) -> String:
        try:
            return self._inner[key.lower()]
        except:
            return String()

    @always_inline
    fn __setitem__(mut self, key: String, value: String):
        self._inner[key.lower()] = value

    fn content_length(self) -> Int:
        try:
            return int(self[HeaderKey.CONTENT_LENGTH])
        except:
            return 0

    fn parse_raw(mut self, mut r: ByteReader) raises -> (String, String, String, List[String]):
        var first_byte = r.peek()
        if not first_byte:
            raise Error("Failed to read first byte from response header")

        var first = r.read_word()
        r.increment()
        var second = r.read_word()
        r.increment()
        var third = r.read_line()
        var cookies = List[String]()

        while not is_newline(r.peek()):
            var key = r.read_until(BytesConstant.colon)
            r.increment()
            if is_space(r.peek()):
                r.increment()
            # TODO (bgreni): Handle possible trailing whitespace
            var value = r.read_line()
            var k = to_string(key).lower()
            if k == HeaderKey.SET_COOKIE:
                cookies.append(to_string(value))
                continue

            self._inner[k] = to_string(value)
        return (to_string(first), to_string(second), to_string(third), cookies)

    fn write_to[T: Writer](self, mut writer: T):
        for header in self._inner.items():
            write_header(writer, header[].key, header[].value)

    fn encode_to(mut self, mut writer: ByteWriter):
        for header in self._inner.items():
            write_header(writer, header[].key, header[].value)

    fn __str__(self) -> String:
        return to_string(self)
