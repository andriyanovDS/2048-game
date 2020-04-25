//
//  RoomListViewController.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class RoomListViewController: UIViewController {
  var viewModel: RoomListViewModel!
  var router: RoomListRouter!
  var roomListView: RoomListView!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    let view = RoomListView()
    view.roomTableView.dataSource = self
    view.roomTableView.delegate = self
    view.roomTableView.register(RoomCellView.self, forCellReuseIdentifier: RoomCellView.reuseIdentifier)
    view.createRoomButton.addTarget(self, action: #selector(onPressCreateRoomButton), for: .touchUpInside)

    viewModel.viewDidLoad()
    viewModel.delegate = self
    self.view = view
    roomListView = view
  }

  @objc private func onPressCreateRoomButton() {
    viewModel.createRoom()
      .then {[weak self] (deviceId, roomId) in
        self?.router.navigateToRoom(isHostUser: true, deviceId: deviceId, roomId: roomId)
      }
      .catch { print($0.localizedDescription) }
  }
}

extension RoomListViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.rooms.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellOptional = tableView.dequeueReusableCell(withIdentifier: RoomCellView.reuseIdentifier)
    guard let cell = cellOptional as? RoomCellView else {
      fatalError("Unexpected cell")
    }

    let room = viewModel.rooms[indexPath.item]
    cell.configureCell(
      title: room.hostName,
      subtitle: "Board size: \(room.boardSize)x\(room.boardSize)"
    )
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let room = viewModel.rooms[indexPath.item]
    viewModel.getDeviceId()
      .then {[weak self] deviceId in
        self?.router.navigateToRoom(isHostUser: false, deviceId: deviceId, roomId: room.id)
      }
  }
}

extension RoomListViewController: RoomListViewModelDelegate {
  func viewModel(_ : RoomListViewModel, didUpdateListWithDiff diffs: [RoomListViewModel.CollectionDiff]) {
    let tableView = roomListView.roomTableView
    tableView.performBatchUpdates({
      diffs.forEach { diff in
        switch diff.type {
        case .insert:
          tableView.insertRows(at: [diff.indexPath], with: .automatic)
        case .update:
          tableView.reloadRows(at: [diff.indexPath], with: .automatic)
        case .delete:
          tableView.deleteRows(at: [diff.indexPath], with: .automatic)
        }
      }
    }, completion: nil)
  }
}
