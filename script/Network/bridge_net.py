import asyncio
import socket

# --- 配置 ---
LISTEN_HOST = '0.0.0.0'  # 监听所有网络接口，让其他机器可以访问
LISTEN_PORT = 12289       # 代理服务器监听的端口

async def pump_data(reader, writer, task_name=""):
    """
    一个数据泵，从一个reader读取数据并写入一个writer。
    用于在客户端和目标服务器之间双向传输数据。
    """
    try:
        while not reader.at_eof():
            data = await reader.read(4096)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except asyncio.CancelledError:
        pass  # 任务被取消是正常操作
    except Exception as e:
        print(f"[{task_name}] 泵数据时发生错误: {e}")
    finally:
        writer.close()
        # print(f"[{task_name}] 连接关闭")

async def handle_client(client_reader, client_writer):
    """
    处理每个客户端连接的主函数。
    """
    addr = client_writer.get_extra_info('peername')
    print(f"[+] 新的连接来自: {addr}")
    
    request_data = None
    try:
        # 读取客户端的初始请求（HTTP请求头）
        request_data = await client_reader.readuntil(b'\r\n\r\n')
    except asyncio.IncompleteReadError:
        print(f"[-] 来自 {addr} 的连接在读取请求头时关闭")
        client_writer.close()
        return

    # 解析请求的第一行，例如 "CONNECT example.com:443 HTTP/1.1"
    first_line = request_data.split(b'\n')[0].decode('utf-8', errors='ignore').strip()
    try:
        method, target, protocol = first_line.split()
    except ValueError:
        print(f"[-] 来自 {addr} 的请求格式不规范: {first_line}")
        client_writer.close()
        return

    print(f"[*] {addr} -> {method} {target}")

    remote_reader, remote_writer = None, None
    try:
        if method.upper() == 'CONNECT':
            # --- 处理 HTTPS CONNECT 请求 ---
            hostname, port_str = target.split(':')
            port = int(port_str)

            # 连接到目标服务器
            remote_reader, remote_writer = await asyncio.open_connection(hostname, port)
            
            # 告诉客户端隧道已建立
            client_writer.write(b'HTTP/1.1 200 Connection Established\r\n\r\n')
            await client_writer.drain()

            # 启动两个数据泵，双向传输数据
            task_c2s = asyncio.create_task(pump_data(client_reader, remote_writer, f"{addr} -> {target}"))
            task_s2c = asyncio.create_task(pump_data(remote_reader, client_writer, f"{target} -> {addr}"))
            
            # 等待两个方向的数据传输完成
            await asyncio.gather(task_c2s, task_s2c)

        else:
            # --- 处理普通 HTTP 请求 ---
            # 解析目标主机
            headers = dict(line.split(b': ', 1) for line in request_data.split(b'\r\n')[1:] if b': ' in line)
            hostname = headers.get(b'Host', b'').decode()
            if not hostname:
                raise ValueError("未找到Host头")
            
            # 连接到目标服务器（HTTP默认80端口）
            remote_reader, remote_writer = await asyncio.open_connection(hostname, 80)
            
            # 将客户端的完整请求转发给目标服务器
            remote_writer.write(request_data)
            await remote_writer.drain()
            
            # 启动数据泵，将服务器响应转发回客户端
            await pump_data(remote_reader, client_writer, f"{hostname} -> {addr}")

    except Exception as e:
        print(f"[!] 处理 {target} 时发生错误: {e}")
    finally:
        # 确保所有连接都已关闭
        if remote_writer:
            remote_writer.close()
        client_writer.close()
        print(f"[-] 连接处理完毕: {addr}")

async def main():
    """
    服务器主入口点。
    """
    server = await asyncio.start_server(
        handle_client, LISTEN_HOST, LISTEN_PORT
    )

    addrs = ', '.join(str(sock.getsockname()) for sock in server.sockets)
    print(f'[*] 代理服务器正在监听于 {addrs}')

    async with server:
        await server.serve_forever()

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[*] 服务器正在关闭...")
