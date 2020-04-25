//
//  RoomListView.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class RoomListView: UIView {
  let roomTableView = UITableView()
  let createRoomButton = ButtonScaleOnPress()

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupHeaderView() -> UIView {
    let headerView = UIView()
    let titleLabel = UILabel()

    titleLabel.text = "Available rooms"
    titleLabel.font = .systemFont(ofSize: 40)
    titleLabel.textColor = .label

    let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
    let plusImage = UIImage(systemName: "plus.app", withConfiguration: imageConfig)
    createRoomButton.setImage(plusImage, for: .normal)
    createRoomButton.tintColor = .systemBlue

    headerView.sv([titleLabel, createRoomButton])
    sv(headerView)
    headerView.left(20).right(20).Top == safeAreaLayoutGuide.Top + 15
    titleLabel.left(0).top(10).bottom(20)
    createRoomButton.right(0).size(44).CenterY == titleLabel.CenterY
    return headerView
  }

  private func setupView() {
    backgroundColor = .systemBackground
    roomTableView.showsVerticalScrollIndicator = false
    roomTableView.isDirectionalLockEnabled = true
    roomTableView.separatorStyle = .none

    sv(roomTableView)
    let headerView = setupHeaderView()
    roomTableView.Top == headerView.Bottom + 5
    roomTableView.bottom(0).left(15).right(15)
    roomTableView.clipsToBounds = false
  }
}
