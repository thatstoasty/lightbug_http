import requests

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
