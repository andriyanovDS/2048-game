//
//  HomeRouter.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class HomeRouter {
  weak var controller: UIViewController?

  func navigateToRoomList() {
    let viewController = RoomListModule.buildDefault()
    viewController.modalPresentationStyle = .fullScreen
    controller?.present(viewController, animated: true, completion: nil)
  }

  func navigateToOffineGameboard() {
    let viewController = GameboardModule.buildDefault(withSize: 4)
    viewController.modalTransitionStyle = .coverVertical
    viewController.modalPresentationStyle = .overFullScreen
    controller?.present(viewController, animated: true, completion: nil)
  }
}
