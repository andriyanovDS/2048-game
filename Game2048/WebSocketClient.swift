//
//  WebSocketClient.swift
//  Game2048
//
//  Created by Dmitry on 24.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import Starscream

class SocketClient {
  weak var delegate: SocketClientDelegate?
  private var socket: WebSocket?
  private lazy var encoder = JSONEncoder()
  private lazy var decoder = JSONDecoder()
  private let serverUrl: URL
  
  init(path: String) {
    serverUrl = URL(string: path, relativeTo: Environment.serverURL)!
  }

  func setupClient(withDeviceId deviceId: String) {
    var request = URLRequest(url: serverUrl)
    request.timeoutInterval = 5
    request.addValue(deviceId, forHTTPHeaderField: "Auth-Token")
    let socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
    self.socket = socket
  }
  
  func write<T: Encodable>(_ data: T) {
    DispatchQueue.global(qos: .default).async {
      do {
        let payload = try self.encoder.encode(data)
        self.socket?.write(string: String(data: payload, encoding: .utf8)!)
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  func decodeMessage<T: Decodable>(_ message: String, completion: @escaping (T) -> Void) {
    DispatchQueue.global(qos: .default).async {
      guard let data = message.data(using: .utf8) else { return}
      do {
        let response = try self.decoder.decode(T.self, from: data)
        DispatchQueue.main.async {
          completion(response)
        }
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }
}

extension SocketClient: WebSocketDelegate {
  func websocketDidConnect(socket: WebSocketClient) {
    delegate?.socketClientDidConnect(self)
  }

  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    delegate?.socketClientDidDisconnect(self, withError: error)
  }
  
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    delegate?.socketClient(self, didReceiveMessage: text)
  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
}

protocol SocketClientDelegate: class {
  func socketClientDidConnect(_: SocketClient)
  func socketClientDidDisconnect(_: SocketClient, withError: Error?)
  func socketClient(_: SocketClient, didReceiveMessage: String)
}

extension SocketClientDelegate {
  func socketClientDidConnect(_: SocketClient) {
    print("WebSocket connection established")
  }

  func socketClientDidDisconnect(_: SocketClient, withError: Error?) {
    print("WebSocket client did disconnect \(withError.map { "with error \($0.localizedDescription)" } ?? "")")
  }
}
