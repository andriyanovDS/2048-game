//
//  HomeViewController.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Foundation

class HomeViewController: UIViewController {
  var router: HomeRouter!
  var homeView: HomeView!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    let view = HomeView()

    view.onlineButton.addTarget(self, action: #selector(setupOnlineGame), for: .touchUpInside)
    view.offlineButton.addTarget(self, action: #selector(setupOfflineGame), for: .touchUpInside)

    self.view = view
    self.homeView = view
  }

  @objc private func setupOnlineGame() {
    router.navigateToRoomList()
  }

  @objc private func setupOfflineGame() {
    router.navigateToOffineGameboard()
  }
}
