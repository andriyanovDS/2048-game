//
//  RoomListRouter.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class RoomListRouter {
  weak var controller: UIViewController?
  
  func navigateToRoom(isHostUser: Bool, deviceId: String, roomId: String) {
    let viewController = GameboardOnlineModule.buildDefault(
      size: 4,
      isHostUser: isHostUser,
      deviceId: deviceId,
      roomId: roomId
    )
    viewController.modalPresentationStyle = .fullScreen
    controller?.present(viewController, animated: true)
  }
}
