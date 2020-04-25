//
//  HomeModule.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class HomeModule {

  static func buildDefault() -> UIViewController {
    let viewController = HomeViewController()
    let router = HomeRouter()
    viewController.router = router
    router.controller = viewController
    return viewController
  }
}
