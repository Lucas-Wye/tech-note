import socket
import threading
import struct


def handle_client(client_socket):
    """处理单个SOCKS5客户端连接"""
    try:
        # 1. 协商阶段: 客户端发送支持的认证方法
        # +----+----------+----------+
        # |VER | NMETHODS | METHODS  |
        # +----+----------+----------+
        # | 1  |    1     | 1 to 255 |
        # +----+----------+----------+
        data = client_socket.recv(256)
        # 我们只支持无需认证的方法 (0x00)
        # 服务器回应选择的方法
        # +----+--------+
        # |VER | METHOD |
        # +----+--------+
        # | 1  |   1    |
        # +----+--------+
        client_socket.sendall(b"\x05\x00")

        # 2. 请求阶段: 客户端发送连接请求
        # +----+-----+-------+------+----------+----------+
        # |VER | CMD |  RSV  | ATYP | DST.ADDR | DST.PORT |
        # +----+-----+-------+------+----------+----------+
        # | 1  |  1  | X'00' |  1   | Variable |    2     |
        # +----+-----+-------+------+----------+----------+
        data = client_socket.recv(4)  # 读取版本、命令、保留位、地址类型
        ver, cmd, rsv, atyp = struct.unpack("!BBBB", data)

        if cmd != 1:  # 仅支持 CONNECT 命令
            client_socket.close()
            return

        if atyp == 1:  # IPv4 地址
            ipv4_addr = client_socket.recv(4)
            host = socket.inet_ntoa(ipv4_addr)
        elif atyp == 3:  # 域名
            domain_len = client_socket.recv(1)[0]
            host = client_socket.recv(domain_len).decode("utf-8")
        elif atyp == 4:  # IPv6 地址
            ipv6_addr = client_socket.recv(16)
            host = socket.inet_ntop(socket.AF_INET6, ipv6_addr)
        else:
            client_socket.close()
            return

        port_data = client_socket.recv(2)
        port = struct.unpack("!H", port_data)[0]

        # 3. 连接目标服务器
        print(f"[*] Requesting connection to {host}:{port}")
        try:
            remote_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            remote_socket.connect((host, port))
        except Exception as e:
            print(f"[!] Error connecting to target: {e}")
            # 发送失败响应
            client_socket.sendall(
                b"\x05\x01\x00\x01\x00\x00\x00\x00\x00\x00"
            )  # 通用失败
            client_socket.close()
            return

        # 4. 回应客户端: 发送成功响应
        # +----+-----+-------+------+----------+----------+
        # |VER | REP |  RSV  | ATYP | BND.ADDR | BND.PORT |
        # +----+-----+-------+------+----------+----------+
        # | 1  |  1  | X'00' |  1   | Variable |    2     |
        # +----+-----+-------+------+----------+----------+
        # 我们简化回应，地址和端口都用0填充
        client_socket.sendall(b"\x05\x00\x00\x01\x00\x00\x00\x00\x00\x00")

        # 5. 数据转发阶段
        print(f"[*] Tunnel established for {host}:{port}")
        forward_data(client_socket, remote_socket)

    except Exception as e:
        print(f"[*] An error occurred: {e}")
    finally:
        client_socket.close()


def forward_data(source, destination):
    """双向转发数据"""
    thread = threading.Thread(target=transfer, args=(destination, source))
    thread.daemon = True
    thread.start()
    transfer(source, destination)


def transfer(source, destination):
    try:
        while True:
            data = source.recv(4096)
            if not data:
                break
            destination.sendall(data)
    except Exception:
        pass
    finally:
        source.close()
        destination.close()


def main():
    listen_host = "0.0.0.0"
    listen_port = 12289  # SOCKS5 代理的默认端口

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((listen_host, listen_port))
    server.listen(100)
    print(f"[*] SOCKS5 Proxy listening on {listen_host}:{listen_port}")

    while True:
        client_socket, addr = server.accept()
        print(f"[*] Accepted connection from {addr[0]}:{addr[1]}")
        thread = threading.Thread(target=handle_client, args=(client_socket,))
        thread.daemon = True
        thread.start()


if __name__ == "__main__":
    main()
