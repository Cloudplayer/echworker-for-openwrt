//go:build linux

package main

import (
	"fmt"
	"log"
	"net"
	"syscall"
	"unsafe"
)

// TPROXY 透明代理支持 (仅 Linux)

// SO_ORIGINAL_DST 常量
const SO_ORIGINAL_DST = 80

// TPROXY 模式常量
const modeTProxy = 4

// tproxyAddr 全局变量（在 main 中通过 flag 设置）
var tproxyAddr string

// getOriginalDst 从 socket 获取原始目标地址（IPv4）
func getOriginalDst(conn net.Conn) (string, error) {
	tcpConn, ok := conn.(*net.TCPConn)
	if !ok {
		return "", fmt.Errorf("not a TCP connection")
	}

	file, err := tcpConn.File()
	if err != nil {
		return "", fmt.Errorf("get file descriptor failed: %v", err)
	}
	defer file.Close()

	fd := int(file.Fd())

	// 使用 getsockopt 获取原始目标地址
	var addr syscall.RawSockaddrInet4
	size := uint32(syscall.SizeofSockaddrInet4)

	_, _, errno := syscall.Syscall6(
		syscall.SYS_GETSOCKOPT,
		uintptr(fd),
		uintptr(syscall.IPPROTO_IP),
		uintptr(SO_ORIGINAL_DST),
		uintptr(unsafe.Pointer(&addr)),
		uintptr(unsafe.Pointer(&size)),
		0,
	)

	if errno != 0 {
		return "", fmt.Errorf("getsockopt SO_ORIGINAL_DST failed: %v", errno)
	}

	// 解析 IP 和端口
	ip := net.IPv4(addr.Addr[0], addr.Addr[1], addr.Addr[2], addr.Addr[3])
	// 端口是网络字节序（大端）
	port := int(addr.Port&0xff)<<8 + int(addr.Port>>8)

	return fmt.Sprintf("%s:%d", ip.String(), port), nil
}

// runTProxyServer 启动 TPROXY 透明代理服务器
func runTProxyServer(addr string) {
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("[TPROXY] 监听失败: %v", err)
	}
	defer listener.Close()

	log.Printf("[TPROXY] 透明代理服务器启动: %s", addr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("[TPROXY] 接受连接失败: %v", err)
			continue
		}

		go handleTProxyConnection(conn)
	}
}

// handleTProxyConnection 处理 TPROXY 连接
func handleTProxyConnection(conn net.Conn) {
	defer conn.Close()

	clientAddr := conn.RemoteAddr().String()

	// 获取原始目标地址
	target, err := getOriginalDst(conn)
	if err != nil {
		log.Printf("[TPROXY] %s 获取原始目标地址失败: %v", clientAddr, err)
		return
	}

	log.Printf("[TPROXY] %s -> %s", clientAddr, target)

	// 使用现有的隧道处理逻辑
	if err := handleTunnel(conn, target, clientAddr, modeTProxy, ""); err != nil {
		if !isNormalCloseError(err) {
			log.Printf("[TPROXY] %s 代理失败: %v", clientAddr, err)
		}
	}
}

// sendTProxyResponse TPROXY 模式的响应处理
func sendTProxyResponse(conn net.Conn) error {
	// TPROXY 透明代理不需要发送响应
	return nil
}
