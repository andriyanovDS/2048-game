//
//  RoomListModule.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class RoomListModule {

  static func buildDefault() -> UIViewController {
    let webSocketClient = SocketClient(path: "roomList")
    let viewModel = RoomListViewModel(webSocketClient: webSocketClient, apiService: APIService.shared)
    let router = RoomListRouter()
    let viewController = RoomListViewController()
    router.controller = viewController
    viewController.router = router
    viewController.viewModel = viewModel

    return viewController
  }
}
