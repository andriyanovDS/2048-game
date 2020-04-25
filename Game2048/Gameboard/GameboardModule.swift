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
    let board = Board(size: size)
    let viewModel = GameboardOfflineViewModelImpl(board: board)
    let router = GameboardRouter()
    let view = GameboardOfflineView()
    let configurator = GameboardViewConfigurator(viewModel: viewModel, view: view)
    let viewController = GameboardOfflineViewController(
      viewModel: viewModel,
      router: router,
      view: view,
      configurator: configurator
    )
    viewModel.delegate = configurator
    configurator.delegate = viewController
    view.boardView.dataSource = configurator
    return viewController
  }
}
