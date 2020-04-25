//
//  RoomCellView.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Stevia
import UIKit

class RoomCellView: UITableViewCell {
  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  private let contentBackgroundView = UIView()

  static let reuseIdentifier = String(describing: RoomCellView.self)

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureCell(title: String, subtitle: String) {
    titleLabel.text = title
    descriptionLabel.text = subtitle
    if layer.shadowPath == nil {
      layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
  }

  private func setupView() {

    contentBackgroundView.backgroundColor = .systemBackground
    contentBackgroundView.layer.cornerRadius = 10
    contentBackgroundView.layer.shadowColor = UIColor.black.cgColor
    contentBackgroundView.layer.shadowOpacity = 0.3
    contentBackgroundView.layer.shadowOffset = .zero
    contentBackgroundView.layer.shadowRadius = 2

    titleLabel.textColor = .label
    titleLabel.font = .systemFont(ofSize: 18)
    descriptionLabel.textColor = .systemGray3
    descriptionLabel.font = .systemFont(ofSize: 15)

    contentBackgroundView.sv([titleLabel, descriptionLabel])
    sv(contentBackgroundView)
    contentBackgroundView.left(0).right(0).top(5).bottom(5)
    titleLabel.left(10).top(10)
    descriptionLabel.left(10).bottom(10).Top == titleLabel.Bottom + 8
  }
}
