//
//  HomeView.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class HomeView: UIView {
  let onlineButton = ButtonScaleOnPress()
  let offlineButton = ButtonScaleOnPress()
  private let titleLabel = UILabel()

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .systemBackground

    titleLabel.text = "2048"
    titleLabel.font = .systemFont(ofSize: 40)
    titleLabel.textColor = .label
    titleLabel.textAlignment = .center

    [onlineButton, offlineButton].forEach { v in
      v.layer.cornerRadius = 10
      v.contentEdgeInsets = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
    }
    onlineButton.setTitle("Play online", for: .normal)
    offlineButton.setTitle("Play offline", for: .normal)

    onlineButton.backgroundColor = .systemBlue
    offlineButton.backgroundColor = .systemTeal

    sv([titleLabel, onlineButton, offlineButton])

    titleLabel.top(90).left(20).right(20)
    onlineButton.Top == CenterY - 50
    offlineButton.Top == onlineButton.Bottom + 40
    onlineButton.centerHorizontally()
    offlineButton.centerHorizontally()
  }
}
