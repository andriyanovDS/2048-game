//
//  CellView.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class CellView: UIView {
  let valueLabel = UILabel()
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func updateValue(_ value: Int) {
    UIView.animate(withDuration: 0.1, animations: {
      self.backgroundColor = CellView.backgroundColor(for: value)
      self.valueLabel.textColor = CellView.fontColor(for: value)
      self.valueLabel.text = String(value)
      self.valueLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }, completion: { _ in
      UIView.animate(withDuration: 0.1, animations: {
        self.valueLabel.transform = .identity
      })
    })
  }
  
  private func setupView() {
    layer.cornerRadius = 10
    valueLabel.font = UIFont.systemFont(ofSize: 20)
    sv(valueLabel)
    valueLabel.centerInContainer()
  }
}

extension CellView {
  static func backgroundColor(for value: Int) -> UIColor {
    switch value {
    case 2:
      return UIColor(red: 238.0/255.0, green: 228.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    case 4:
      return UIColor(red: 237.0/255.0, green: 224.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    case 8:
      return UIColor(red: 242.0/255.0, green: 177.0/255.0, blue: 121.0/255.0, alpha: 1.0)
    case 16:
      return UIColor(red: 245.0/255.0, green: 149.0/255.0, blue: 99.0/255.0, alpha: 1.0)
    case 32:
      return UIColor(red: 246.0/255.0, green: 124.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    case 64:
      return UIColor(red: 246.0/255.0, green: 94.0/255.0, blue: 59.0/255.0, alpha: 1.0)
    default:
      return UIColor(red: 237.0/255.0, green: 207.0/255.0, blue: 114.0/255.0, alpha: 1.0)
    }
  }
  
  static func fontColor(for value: Int) -> UIColor {
    switch value {
    case 2, 4:
      return UIColor(red: 119.0/255.0, green: 110.0/255.0, blue: 101.0/255.0, alpha: 1.0)
    default: return .white
    }
  }
}
