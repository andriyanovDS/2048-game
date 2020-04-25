//
//  GameboardOfflineView.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class GameboardOfflineView: UIView, GameboardConfiguredView {
  let boardView = BoardView()
  let undoButton = UIButton()
  let restartButton = UIButton()
  private let scoreTitleLabel = UILabel()
  private let scoreValueLabel = UILabel()
  private var cellViews: [IndexPath: [CellView]] = [:]
  
  struct Constants {
    static let boardWidth: CGFloat = UIScreen.main.bounds.width - 40
  }
  
  func viewDidLoad() {
    setupView()
    boardView.parentViewDidLoad()
  }
  
  func setScore(_ score: Int) {
    scoreValueLabel.text = String(score)
  }
  
  private func setupView() {
    backgroundColor = .systemGray6
    
    [scoreTitleLabel, scoreValueLabel]
      .forEach { v in
        v.textColor = .label
        v.font = .systemFont(ofSize: 40)
      }
    scoreTitleLabel.text = "Score:"
    scoreValueLabel.text = "0"
    
    [(undoButton, "gobackward"), (restartButton, "repeat")]
      .forEach { (button, iconName) in
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let undoImage = UIImage(systemName: iconName, withConfiguration: imageConfig)
        button.setImage(undoImage, for: .normal)
        button.tintColor = .systemGray2
      }
    
    sv([scoreTitleLabel, scoreValueLabel, boardView, restartButton, undoButton])
    scoreTitleLabel.left(20)
    scoreTitleLabel.Bottom == boardView.Top - 40
    scoreValueLabel.CenterY == scoreTitleLabel.CenterY
    scoreValueLabel.Left == scoreTitleLabel.Right + 5
    undoButton.CenterY == scoreValueLabel.CenterY
    restartButton.CenterY == undoButton.CenterY
    restartButton.right(20)
    undoButton.Right == restartButton.Left - 20
    boardView
      .size(Constants.boardWidth)
      .centerInContainer()
  }
}
