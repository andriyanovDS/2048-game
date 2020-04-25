//
//  APIService.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Promises
import Foundation

protocol NetworkService {
  func createDeviceId() -> Promise<String>
  func createRoom(params: CreateRoomParams) -> Promise<String>
}

class APIService: NetworkService {
  private lazy var session = URLSession.shared

  static let shared = APIService()

  func createDeviceId() -> Promise<String> {
    let url = self.url(for: "deviceId")
    let request = URLRequest(url: url)
    return Promise { resolve, reject in
      let task = self.session.dataTask(with: request, completionHandler: { data, _, error in
        if let error = error {
          reject(error)
          return
        }
        do {
          let result = try JSONDecoder().decode(DeviceIdResponse.self, from: data!)
          resolve(result.deviceId)
        } catch let error {
          reject(error)
        }
      })
      task.resume()
    }
  }
  
  func createRoom(params: CreateRoomParams) -> Promise<String> {
    let url = self.url(for: "room")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return Promise(on: .global()) { resolve, reject in
      request.httpBody = try JSONEncoder().encode(params)
      let task = self.session.dataTask(with: request, completionHandler: { data, _, error in
        if let error = error {
          reject(error)
          return
        }
        do {
          let result = try JSONDecoder().decode(CreateRoomResponse.self, from: data!)
          resolve(result.roomId)
        } catch let error {
          reject(error)
        }
      })
      task.resume()
    }
  }

  private func url(for path: String, with params: [String: String] = [:]) -> URL {
    let url = URL(string: path, relativeTo: Environment.serverURL)!

    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    if !params.isEmpty {
      components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    return components.url!
  }
}

extension APIService {
  struct DeviceIdResponse: Decodable {
    let deviceId: String
  }
  struct CreateRoomResponse: Decodable {
    let roomId: String
  }
}

struct CreateRoomParams: Encodable {
  let hostName: String
  let deviceId: String
  let boardSize: Int
}
