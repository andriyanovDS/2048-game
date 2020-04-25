//
//  RoomListViewModel.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Promises
import Foundation

class RoomListViewModel {
  var rooms: [Room] = []
  weak var delegate: RoomListViewModelDelegate?
  private var storage = Storage()
  private let apiService: NetworkService
  private let webSocketClient: SocketClient

  init(
    webSocketClient: SocketClient,
    apiService: NetworkService
  ) {
    self.webSocketClient = webSocketClient
    self.apiService = apiService
  }

  func viewDidLoad() {
    setupWebSocketClient()
  }

  func getDeviceId() -> Promise<String> {
    if let deviceId = storage.deviceId {
      return Promise(deviceId)
    }
    return apiService.createDeviceId()
      .then {[weak self] id -> String in
        self?.storage.deviceId = id
        return id
      }
  }
  
  func createRoom() -> Promise<(deviceId: String, roomId: String)> {
    return Promise<(deviceId: String, roomId: String)>(on: .global()) {() -> (deviceId: String, roomId: String) in
      let deviceId = try await(self.getDeviceId())
      let createRoomParams = CreateRoomParams(
        hostName: "Host name",
        deviceId: deviceId,
        boardSize: 4
      )
      let roomId = try await(self.apiService.createRoom(params: createRoomParams))
      return (deviceId, roomId)
    }
  }

  private func setupWebSocketClient() {
    getDeviceId()
      .then {[weak self] id in
        guard let self = self else { return }
        self.webSocketClient.delegate = self
        self.webSocketClient.setupClient(withDeviceId: id)
      }
      .catch { print($0.localizedDescription) }
  }

  private func handleReceivedEvent(_ event: RoomListChangeEvent) -> CollectionDiff? {
    switch event.type {
    case .insert:
      rooms.append(event.data)
      return CollectionDiff(type: .insert, indexPath: IndexPath(item: rooms.count - 1, section: 0))
    case .update:
      guard let index = rooms.firstIndex(where: { $0.id == event.documentId }) else {
        return nil
      }
      rooms[index] = event.data
      return CollectionDiff(type: .update, indexPath: IndexPath(item: index, section: 0))
    case .delete:
      guard let index = rooms.firstIndex(where: { $0.id == event.documentId }) else {
        return nil
      }
      rooms.remove(at: index)
      return CollectionDiff(type: .update, indexPath: IndexPath(item: index, section: 0))
    }
  }
}

protocol RoomListViewModelDelegate: class {
  func viewModel(_: RoomListViewModel, didUpdateListWithDiff: [RoomListViewModel.CollectionDiff])
}

extension RoomListViewModel: SocketClientDelegate {
  func socketClient(_ client: SocketClient, didReceiveMessage message: String) {
    client.decodeMessage(message) {[unowned self] (events: [RoomListChangeEvent]) in
      let diffs = events.compactMap { self.handleReceivedEvent($0) }
      self.delegate?.viewModel(self, didUpdateListWithDiff: diffs)
    }
  }
}

extension RoomListViewModel {
  enum ChangeListEventType: String, Codable {
    case insert
    case update
    case delete
  }

  struct Room: Codable {
    let id: String
    let hostId: String
    let hostName: String
    let boardSize: Int
  }

  struct RoomListChangeEvent: Codable {
    let documentId: String
    let type: ChangeListEventType
    let data: Room
  }

  struct CollectionDiff {
    let type: ChangeListEventType
    let indexPath: IndexPath
  }
}
