from lightbug_http.io.bytes import Bytes, BytesView, bytes_equal, bytes
from lightbug_http.strings import (
    strSlash,
    strHttp11,
    strHttp10,
    strHttp,
    http,
    strHttps,
    https,
)


@value
struct URI:
    var __path_original: Bytes
    var __scheme: Bytes
    var __path: Bytes
    var __query_string: Bytes
    var __hash: Bytes
    var __host: Bytes
    var __http_version: Bytes

    var disable_path_normalization: Bool

    var __full_uri: Bytes
    var __request_uri: Bytes

    var __username: Bytes
    var __password: Bytes

    @always_inline
    fn __init__(
        inout self,
        full_uri: String,
    ) -> None:
        self.__path_original = Bytes()
        self.__scheme = Bytes()
        self.__path = Bytes()
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = Bytes()
        self.__http_version = Bytes()
        self.disable_path_normalization = False
        self.__full_uri = bytes(full_uri, pop=False)
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()
    
    @always_inline
    fn __init__(
        inout self,
        full_uri: String,
        host: String
    ) -> None:
        self.__path_original = Bytes()
        self.__scheme = Bytes()
        self.__path = Bytes()
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = bytes(host)
        self.__http_version = Bytes()
        self.disable_path_normalization = False
        self.__full_uri = bytes(full_uri)
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()

    @always_inline
    fn __init__(
        inout self,
        scheme: String,
        host: String,
        path: String,
    ) -> None:
        self.__path_original = bytes(path)
        self.__scheme = scheme.as_bytes()
        self.__path = normalise_path(bytes(path), self.__path_original)
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = bytes(host)
        self.__http_version = Bytes()
        self.disable_path_normalization = False
        self.__full_uri = Bytes()
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()

    @always_inline
    fn __init__(
        inout self,
        path_original: Bytes,
        path: Bytes,
        scheme: Bytes,
        query_string: Bytes,
        hash: Bytes,
        host: Bytes,
        http_version: Bytes,
        disable_path_normalization: Bool,
        full_uri: Bytes,
        request_uri: Bytes,
        username: Bytes,
        password: Bytes,
    ):
        self.__path_original = path_original
        self.__scheme = scheme
        self.__path = path
        self.__query_string = query_string
        self.__hash = hash
        self.__host = host
        self.__http_version = http_version
        self.disable_path_normalization = disable_path_normalization
        self.__full_uri = full_uri
        self.__request_uri = request_uri
        self.__username = username
        self.__password = password

    @always_inline
    fn path_original(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__path_original.unsafe_ptr(), len=self[].__path_original.size)

    @always_inline
    fn set_path(inout self, path: String) -> Self:
        self.__path = normalise_path(bytes(path), self.__path_original)
        return self

    @always_inline
    fn set_path_sbytes(inout self, path: Bytes) -> Self:
        self.__path = normalise_path(path, self.__path_original)
        return self

    @always_inline
    fn path(self) -> String:
        if len(self.__path) == 0:
            return strSlash
        return String(self.__path)
    
    @always_inline
    fn path_bytes(self: Reference[Self]) -> BytesView:
        if len(self[].__path) == 0:
            return BytesView(unsafe_ptr=strSlash.as_bytes_slice().unsafe_ptr(), len=2)
        return BytesView(unsafe_ptr=self[].__path.unsafe_ptr(), len=self[].__path.size)

    @always_inline
    fn set_scheme(inout self, scheme: String) -> Self:
        self.__scheme = bytes(scheme)
        return self

    @always_inline
    fn set_scheme_bytes(inout self, scheme: Bytes) -> Self:
        self.__scheme = scheme
        return self

    @always_inline
    fn scheme(self: Reference[Self]) -> BytesView:
        if len(self[].__scheme) == 0:
            return BytesView(unsafe_ptr=strHttp.as_bytes_slice().unsafe_ptr(), len=5)
        return BytesView(unsafe_ptr=self[].__scheme.unsafe_ptr(), len=self[].__scheme.size)

    @always_inline
    fn http_version(self: Reference[Self]) -> BytesView:
        if len(self[].__http_version) == 0:
            return BytesView(unsafe_ptr=strHttp11.as_bytes_slice().unsafe_ptr(), len=9)
        return BytesView(unsafe_ptr=self[].__http_version.unsafe_ptr(), len=self[].__http_version.size)

    @always_inline
    fn http_version_str(self) -> String:
        return self.__http_version

    @always_inline
    fn set_http_version(inout self, http_version: String) -> Self:
        self.__http_version = bytes(http_version)
        return self
    
    @always_inline
    fn set_http_version_bytes(inout self, http_version: Bytes) -> Self:
        self.__http_version = http_version
        return self

    @always_inline
    fn is_http_1_1(self) -> Bool:
        return bytes_equal(self.http_version(), bytes(strHttp11, pop=False))

    @always_inline
    fn is_http_1_0(self) -> Bool:
        return bytes_equal(self.http_version(), bytes(strHttp10, pop=False))

    @always_inline
    fn is_https(self) -> Bool:
        return bytes_equal(self.__scheme, bytes(https, pop=False))

    @always_inline
    fn is_http(self) -> Bool:
        return bytes_equal(self.__scheme, bytes(http, pop=False)) or len(self.__scheme) == 0

    @always_inline
    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = bytes(request_uri)
        return self

    @always_inline
    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self
    
    @always_inline
    fn request_uri(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__request_uri.unsafe_ptr(), len=self[].__request_uri.size)

    @always_inline
    fn set_query_string(inout self, query_string: String) -> Self:
        self.__query_string = bytes(query_string)
        return self

    @always_inline
    fn set_query_string_bytes(inout self, query_string: Bytes) -> Self:
        self.__query_string = query_string
        return self
    
    @always_inline
    fn query_string(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__query_string.unsafe_ptr(), len=self[].__query_string.size)

    @always_inline
    fn set_hash(inout self, hash: String) -> Self:
        self.__hash = bytes(hash)
        return self

    @always_inline
    fn set_hash_bytes(inout self, hash: Bytes) -> Self:
        self.__hash = hash
        return self

    @always_inline
    fn hash(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__hash.unsafe_ptr(), len=self[].__hash.size)

    @always_inline
    fn set_host(inout self, host: String) -> Self:
        self.__host = bytes(host)
        return self

    @always_inline
    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    @always_inline
    fn host(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__host.unsafe_ptr(), len=self[].__host.size)
    
    @always_inline
    fn host_str(self) -> String:
        return self.__host

    @always_inline
    fn full_uri(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__full_uri.unsafe_ptr(), len=self[].__full_uri.size)

    @always_inline
    fn set_username(inout self, username: String) -> Self:
        self.__username = bytes(username)
        return self

    @always_inline
    fn set_username_bytes(inout self, username: Bytes) -> Self:
        self.__username = username
        return self
    
    @always_inline
    fn username(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__username.unsafe_ptr(), len=self[].__username.size)

    @always_inline
    fn set_password(inout self, password: String) -> Self:
        self.__password = bytes(password)
        return self

    @always_inline
    fn set_password_bytes(inout self, password: Bytes) -> Self:
        self.__password = password
        return self
    
    @always_inline
    fn password(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__password.unsafe_ptr(), len=self[].__password.size)

    @always_inline
    fn parse(inout self) raises -> None:
        var raw_uri = String(self.__full_uri)

        var proto_str = String(strHttp11)
        var is_https = False

        var proto_end = raw_uri.find("://")
        var remainder_uri: String
        if proto_end >= 0:
            proto_str = raw_uri[:proto_end]
            if proto_str == https:
                is_https = True
            remainder_uri = raw_uri[proto_end + 3:]
        else:
            remainder_uri = raw_uri

        _ = self.set_scheme_bytes(proto_str.as_bytes_slice())
        
        var path_start = remainder_uri.find("/")
        var host_and_port: String
        var request_uri: String
        if path_start >= 0:
            host_and_port = remainder_uri[:path_start]
            request_uri = remainder_uri[path_start:]
            _ = self.set_host_bytes(bytes(host_and_port[:path_start], pop=False))
        else:
            host_and_port = remainder_uri
            request_uri = strSlash
            _ = self.set_host_bytes(bytes(host_and_port, pop=False))

        if is_https:
            _ = self.set_scheme_bytes(bytes(https, pop=False))
        else:
            _ = self.set_scheme_bytes(bytes(http, pop=False))
        
        var n = request_uri.find("?")
        if n >= 0:
            self.__path_original = bytes(request_uri[:n], pop=False)
            self.__query_string = bytes(request_uri[n + 1 :], pop=False)
        else:
            self.__path_original = bytes(request_uri, pop=False)
            self.__query_string = Bytes()

        _ = self.set_path_sbytes(normalise_path(self.__path_original, self.__path_original))

        _ = self.set_request_uri_bytes(bytes(request_uri, pop=False))


fn normalise_path(path: Bytes, path_original: Bytes) -> Bytes:
    # TODO: implement
    return path
