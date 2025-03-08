import requests
import socket
import time

session = requests.Session()

print("\n~~~ Testing redirect ~~~")
response = session.get('http://127.0.0.1:8080/redirect', allow_redirects=True)
assert response.status_code == 200
assert response.text == "yay you made it"

print("\n~~~ Testing close connection ~~~")
response = session.get('http://127.0.0.1:8080/close-connection', headers={'connection': 'close'})
assert response.status_code == 200
assert response.text == "connection closed"

print("\n~~~ Testing internal server error ~~~")
response = session.get('http://127.0.0.1:8080/error', headers={'connection': 'keep-alive'})
assert response.status_code == 500

print("\n~~~ Testing large headers ~~~")
large_headers = {
    f'X-Custom-Header-{i}': 'value' * 100  # long value
    for i in range(8)  # minimum number to exceed default buffer size (4096)
}
response = session.get('http://127.0.0.1:8080/large-headers', headers=large_headers)
assert response.status_code == 200

print("\n~~~ Testing content-length mismatch (smaller) ~~~")
def test_content_length_smaller():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send a request with Content-Length larger than actual body
    s.sendall(b'POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 100\r\n\r\nOnly sending 20 bytes')
    # Try to receive response
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 400 Bad Request
        assert b"400 Bad Request" in data
    except:
        pass
    finally:
        s.close()

test_content_length_smaller()
time.sleep(1)

print("\n~~~ Testing abrupt connection close during read ~~~")
def test_abrupt_close_during_read():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send a partial request that will make the server wait for more data
    s.sendall(b'GET / HTTP/1.1\r\n')
    # Close the socket abruptly without sending the complete request
    s.close()

test_abrupt_close_during_read()
time.sleep(1)

print("\n~~~ Testing invalid request method ~~~")
def test_invalid_request_method():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send an invalid HTTP method
    s.sendall(b'INVALID / HTTP/1.1\r\nHost: localhost\r\n\r\n')
    # Try to receive response
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 400 Bad Request
        assert b"400 Bad Request" in data
    except:
        pass
    finally:
        s.close()

test_invalid_request_method()
time.sleep(1)

print("\n~~~ Testing malformed headers ~~~")
def test_malformed_headers():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send a request with malformed headers
    s.sendall(b'GET / HTTP/1.1\r\nMalformed-Header\r\n\r\n')
    # Try to receive response
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 400 Bad Request
        assert b"400 Bad Request" in data
    except:
        pass
    finally:
        s.close()

test_malformed_headers()
time.sleep(1)

print("\n~~~ Testing oversized request body ~~~")
def test_oversized_request_body():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Assuming max_body_size is set to a reasonable value (e.g., 1MB)
    # Send a request with a Content-Length exceeding the limit
    s.sendall(b'POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 10000000\r\n\r\n')
    # Try to receive response
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 400 Bad Request
        assert b"400 Bad Request" in data
    except:
        pass
    finally:
        s.close()

test_oversized_request_body()
time.sleep(1)

print("\n~~~ Testing half-closed connection ~~~")
def test_half_closed_connection():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send a complete request
    s.sendall(b'GET / HTTP/1.1\r\nHost: localhost\r\n\r\n')
    # Shutdown the write side but keep read side open
    s.shutdown(socket.SHUT_WR)
    # Try to receive response
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 200 OK
        assert b"200 OK" in data
    except:
        pass
    finally:
        s.close()

test_half_closed_connection()
time.sleep(1)

print("\n~~~ Testing connection with invalid Content-Length ~~~")
def test_invalid_content_length():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send a request with invalid (negative) Content-Length
    s.sendall(b'POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: -1\r\n\r\n')
    # Try to receive response
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 400 Bad Request
        assert b"400 Bad Request" in data
    except:
        pass
    finally:
        s.close()

test_invalid_content_length()
time.sleep(1)

print("\n~~~ Testing pipelined requests ~~~")
def test_pipelined_requests():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8080))
    # Send multiple requests without waiting for responses
    s.sendall(b'GET /first HTTP/1.1\r\nHost: localhost\r\n\r\nGET /second HTTP/1.1\r\nHost: localhost\r\n\r\n')
    # Try to receive responses
    try:
        data = s.recv(4096)
        print(f"Response: {data.decode('utf-8', errors='ignore')}")
        # Check if response contains 200 OK
        assert b"200 OK" in data
    except:
        pass
    finally:
        s.close()

test_pipelined_requests()
time.sleep(1)

print("\n~~~ All tests completed ~~~")
