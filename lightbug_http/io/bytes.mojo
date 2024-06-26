from python import PythonObject

alias Bytes = List[Int8]

fn bytes(s: StringLiteral) -> Bytes:
    # This is currently null-terminated, which we don't want in HTTP responses
    var buf = String(s)._buffer
    _ = buf.pop()
    return buf

fn bytes(s: String) -> Bytes:
    # This is currently null-terminated, which we don't want in HTTP responses
    var buf = s._buffer
    _ = buf.pop()
    return buf

@value
@register_passable("trivial")
struct UnsafeString:
    var data: Pointer[Int8]
    var len: Int

    fn __init__(str: StringLiteral) -> UnsafeString:
        var l = str.__len__()
        var s = String(str)
        var p = Pointer[Int8].alloc(l)
        for i in range(l):
            p.store(i, s._buffer[i])
        return UnsafeString(p, l)

    fn __init__(str: String) -> UnsafeString:
        var l = str.__len__()
        var p = Pointer[Int8].alloc(l)
        for i in range(l):
            p.store(i, str._buffer[i])
        return UnsafeString(p, l)

    fn to_string(self) -> String:
        var s = String(self.data, self.len)
        return s


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)
