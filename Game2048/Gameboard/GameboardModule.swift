//
//  GameboardModule.swift
//  Game2048
//
//  Created by Dmitry on 23.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class GameboardModule {
  
  static func buildDefault(withSize size: Int) -> UIViewController {
    let viewModel = GameboardViewModelImpl(size: size)
    let router = GameboardRouter()
    return GameboardViewController(viewModel: viewModel, router: router)
  }
}
