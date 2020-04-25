//
//  GameboardNetworkClient.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class GameboardNetworkClient {
  weak var delegate: GameboardNetworkClientDelegate?
  private let isHostUser: Bool
  private let deviceId: String
  private let webSocketClient: SocketClient
  private let viewModel: GameboardOnlineViewModel
  private var isActionAvailable: Bool

  init(
    webSocketClient: SocketClient,
    isHostUser: Bool,
    deviceId: String,
    viewModel: GameboardOnlineViewModel
  ) {
    self.viewModel = viewModel
    self.deviceId = deviceId
    self.isHostUser = isHostUser
    self.webSocketClient = webSocketClient
    self.isActionAvailable = isHostUser
  }

  func setupWebSocketClient() {
    webSocketClient.delegate = self
    webSocketClient.setupClient(withDeviceId: deviceId)
    let opponentState: OpponentState = isHostUser
      ? .waiting
      : .connected(isOpponentMove: true)
    delegate?.networkClient(self, didChangeOpponentState: opponentState)
  }
  
  func onUserAction(to direction: UserActionDirection) {
    if !isActionAvailable { return }
    switch direction {
    case .up:
      viewModel.moveUp()
    case .down:
      viewModel.moveDown()
    case .left:
      viewModel.moveLeft()
    case .right:
      viewModel.moveRight()
    }
    viewModel.addRandomCell()
    sendAction(direction)
  }
  
  private func sendAction(_ direction: UserActionDirection) {
    isActionAvailable = false
    let cell = viewModel.cells.last
    let event = RoomEventType.action(action: OpponentAction(
      direction: direction,
      generatedCell: cell.map { SharedCell(position: $0.position, value: $0.value) }
    ))
    webSocketClient.write(event)
    delegate?.networkClient(self, didChangeOpponentState: .connected(isOpponentMove: true))
  }

  private func onUserDidChange(_ users: [String]) {
    if users.count < 2 {
      delegate?.networkClient(self, didChangeOpponentState: .disconnected)
    } else if isHostUser {
      delegate?.networkClient(
        self,
        didChangeOpponentState: .connected(isOpponentMove: !isActionAvailable)
      )
    }
  }

  private func onOpponentAction(_ action: OpponentAction) {
    switch action.direction {
    case .left:
      viewModel.moveLeft()
    case .right:
      viewModel.moveRight()
    case .up:
      viewModel.moveUp()
    case .down:
      viewModel.moveDown()
    }
    if let cell = action.generatedCell {
      viewModel.appendOpponentCell(cell)
    }
    isActionAvailable = true
    delegate?.networkClient(self, didChangeOpponentState: .connected(isOpponentMove: false))
  }

  private func setInitialCells(_ cells: [SharedCell]) {
    viewModel.viewDidLoad(withState: .predefined(cells: cells))
  }
}

extension GameboardNetworkClient: SocketClientDelegate {
  func socketClientDidConnect(_: SocketClient) {
    if isHostUser {
      viewModel.viewDidLoad(withState: .random)
      let event = RoomEventType.initialCells(cells: viewModel.cells.map {
        SharedCell(position: $0.position, value: $0.value)
      })
      webSocketClient.write(event)
    }
  }

  func socketClientDidDisconnect(_: SocketClient, withError: Error?) {}

  func socketClient(_ client: SocketClient, didReceiveMessage message: String) {
    client.decodeMessage(message) {[unowned self] (event: GameExternalEvent) in
      if let users = event.users {
        self.onUserDidChange(users)
        return
      }
      if let action = event.action {
        self.onOpponentAction(action)
        return
      }
      if let initialCells = event.initialCells {
        self.setInitialCells(initialCells)
      }
    }
  }
}

enum OpponentState {
  case waiting
  case connected(isOpponentMove: Bool)
  case disconnected
}

protocol GameboardNetworkClientDelegate: class {
  func networkClient(_: GameboardNetworkClient, didChangeOpponentState: OpponentState)
}

struct SharedCell: Codable {
  let position: IndexPath
  let value: Int
}

struct OpponentAction: Codable {
  let direction: UserActionDirection
  let generatedCell: SharedCell?
}

struct GameExternalEvent: Decodable {
  let users: [String]?
  let action: OpponentAction?
  let initialCells: [SharedCell]?
}

enum RoomEventType: Codable {
  case initialCells(cells: [SharedCell])
  case action(action: OpponentAction)
}

extension RoomEventType {
  private enum CodingKeys: String, CodingKey {
    case initialCells
    case action
    case type
    case direction
    case generatedCell
  }
  
  enum PostTypeCodingError: Error {
    case decoding(String)
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try? values.decode([SharedCell].self, forKey: .initialCells) {
      self = .initialCells(cells: value)
      return
    }
    if let value = try? values.decode(OpponentAction.self, forKey: .action) {
      self = .action(action: value)
      return
    }
    throw PostTypeCodingError.decoding("Whoops! \(dump(values))")
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .initialCells(let cells):
      try container.encode("initialCells", forKey: .type)
      try container.encode(cells, forKey: .initialCells)
    case .action(let action):
      try container.encode("opponentAction", forKey: .type)
      try container.encode(action.direction, forKey: .direction)
      try container.encode(action.generatedCell, forKey: .generatedCell)
    }
  }
}
