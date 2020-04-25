//
//  GameboardOnlineModule.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class GameboardOnlineModule {
  static func buildDefault(size: Int, isHostUser: Bool, deviceId: String, roomId: String) -> UIViewController {
    let board = Board(size: size)
    let viewModel = GameboardOnlineViewModelImpl(board: board)
    let view = GameboardOnlineView()
    let webSocketClient = SocketClient(path: "room?roomId=\(roomId)")
    let networkClient = GameboardNetworkClient(
      webSocketClient: webSocketClient,
      isHostUser: isHostUser,
      deviceId: deviceId,
      viewModel: viewModel
    )
    let configurator = GameboardViewConfigurator(viewModel: viewModel, view: view)
    let viewController = GameboardOnlineViewController(
      view: view,
      viewModel: viewModel,
      configurator: configurator,
      networkClient: networkClient
    )
    viewModel.delegate = configurator
    configurator.delegate = viewController
    view.boardView.dataSource = configurator
    networkClient.delegate = viewController
    return viewController
  }
}
