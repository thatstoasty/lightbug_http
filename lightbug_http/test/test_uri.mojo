from testing import assert_equal
from lightbug_http.uri import URI
from lightbug_http.strings import empty_string
from lightbug_http.io.bytes import Bytes

def test_uri():
    test_uri_parse()

def test_uri_parse():
    var uri_no_parse_defaults = URI("http://example.com")
    assert_equal(uri_no_parse_defaults.full_uri(), "http://example.com")
    assert_equal(uri_no_parse_defaults.scheme(), "http")
    assert_equal(uri_no_parse_defaults.host(), "127.0.0.1")
    assert_equal(uri_no_parse_defaults.path(), "/")
    
    var uri_http_with_port = URI("http://example.com:8080/index.html")
    _ = uri_http_with_port.parse()
    assert_equal(uri_http_with_port.scheme(), "http")
    assert_equal(uri_http_with_port.host(), "example.com:8080")
    assert_equal(uri_http_with_port.path(), "/index.html")
    assert_equal(uri_http_with_port.path_original(), "/index.html")
    assert_equal(uri_http_with_port.request_uri(), "/index.html")
    assert_equal(uri_http_with_port.http_version(), "HTTP/1.1")
    assert_equal(uri_http_with_port.is_http_1_0(), False)
    assert_equal(uri_http_with_port.is_http_1_1(), True)
    assert_equal(uri_http_with_port.is_https(), False)
    assert_equal(uri_http_with_port.is_http(), True)
    assert_equal(uri_http_with_port.query_string(), empty_string)
    
    var uri_https_with_port = URI("https://example.com:8080/index.html")
    _ = uri_https_with_port.parse()
    assert_equal(uri_https_with_port.scheme(), "https")
    assert_equal(uri_https_with_port.host(), "example.com:8080")
    assert_equal(uri_https_with_port.path(), "/index.html")
    assert_equal(uri_https_with_port.path_original(), "/index.html")
    assert_equal(uri_https_with_port.request_uri(), "/index.html")
    assert_equal(uri_https_with_port.is_https(), True)
    assert_equal(uri_https_with_port.is_http(), False)
    assert_equal(uri_https_with_port.query_string(), empty_string)

    uri_http_with_path = URI("http://example.com/index.html")
    _ = uri_http_with_path.parse()
    assert_equal(uri_http_with_path.scheme(), "http")
    assert_equal(uri_http_with_path.host(), "example.com")
    assert_equal(uri_http_with_path.path(), "/index.html")
    assert_equal(uri_http_with_path.path_original(), "/index.html")
    assert_equal(uri_http_with_path.request_uri(), "/index.html")
    assert_equal(uri_http_with_path.is_https(), False)
    assert_equal(uri_http_with_path.is_http(), True)
    assert_equal(uri_http_with_path.query_string(), empty_string)


    uri_https_with_path = URI("https://example.com/index.html")
    _ = uri_https_with_path.parse()
    assert_equal(uri_https_with_path.scheme(), "https")
    assert_equal(uri_https_with_path.host(), "example.com")
    assert_equal(uri_https_with_path.path(), "/index.html")
    assert_equal(uri_https_with_path.path_original(), "/index.html")
    assert_equal(uri_https_with_path.request_uri(), "/index.html")
    assert_equal(uri_https_with_path.is_https(), True)
    assert_equal(uri_https_with_path.is_http(), False)
    assert_equal(uri_https_with_path.query_string(), empty_string)

    uri_http = URI("http://example.com")
    _ = uri_http.parse()
    assert_equal(uri_http.scheme(), "http")
    assert_equal(uri_http.host(), "example.com")
    assert_equal(uri_http.path(), "/")
    assert_equal(uri_http.path_original(), "/")
    assert_equal(uri_http.http_version(), "HTTP/1.1")
    assert_equal(uri_http.request_uri(), "/")
    assert_equal(uri_http.query_string(), empty_string)

    uri_http_with_www = URI("http://www.example.com")
    _ = uri_http_with_www.parse()
    assert_equal(uri_http_with_www.scheme(), "http")
    assert_equal(uri_http_with_www.host(), "www.example.com")
    assert_equal(uri_http_with_www.path(), "/")
    assert_equal(uri_http_with_www.path_original(), "/")
    assert_equal(uri_http_with_www.request_uri(), "/")
    assert_equal(uri_http_with_www.http_version(), "HTTP/1.1")
    assert_equal(uri_http_with_www.query_string(), empty_string)

    # uri = URI("http://example.com/index.html?name=John&age=30")
    # _ = uri.parse()
    # assert_equal(uri.scheme(), "http")
    # assert_equal(uri.host(), "example.com")
    # assert_equal(uri.path(), "/index.html")
    # assert_equal(uri.path_original(), "/index.html")
    # assert_equal(uri.http_version(), "HTTP/1.1")
    # assert_equal(uri.request_uri(), "/index.html")
    # assert_equal(uri.query_string(), "name=John&age=30")
    # assert_equal(uri.host(), "example.com")

    # uri = URI("http://example.com/index.html#section1")
    # _ = uri.parse()
    # assert_equal(uri.scheme(), "http")
    # assert_equal(uri.host(), "example.com")
    # assert_equal(uri.path(), "/index.html")
    # assert_equal(uri.path_original(), "/index.html")
    # assert_equal(uri.http_version(), "HTTP/1.1")
    # assert_equal(uri.hash(), "section1")
    # assert_equal(uri.query_string(), empty_string)

    # uri = URI("http://example.com/index.html?name=John&age=30#section1")
    # _ = uri.parse()
    # assert_equal(uri.scheme(), "http")
    # assert_equal(uri.host(), "example.com")
    # assert_equal(uri.path(), "/index.html")
    # assert_equal(uri.path_original(), "/index.html")
    # assert_equal(uri.request_uri(), "/index.html")
    # assert_equal(uri.hash(), "section1")
    # assert_equal(uri.query_string(), "name=John&age=30")
    # assert_equal(uri.host(), "example.com")

