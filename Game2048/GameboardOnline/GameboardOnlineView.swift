//
//  GameboardOnlineView.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class GameboardOnlineView: UIView, GameboardConfiguredView {
  let boardView = BoardView()
  let opponentStateValueLabel = UILabel()
  private let scoreTitleLabel = UILabel()
  private let scoreValueLabel = UILabel()
  
  func viewDidLoad() {
    setupView()
    boardView.parentViewDidLoad()
  }
  
  func setScore(_ score: Int) {
    scoreValueLabel.text = String(score)
  }
  
  private func setupView() {
    backgroundColor = .systemGray6
    
    opponentStateValueLabel.textColor = .secondaryLabel
    opponentStateValueLabel.font = .systemFont(ofSize: 32)
    
    [scoreTitleLabel, scoreValueLabel]
      .forEach { v in
        v.textColor = .label
        v.font = .systemFont(ofSize: 40)
    }
    scoreTitleLabel.text = "Score:"
    scoreValueLabel.text = "0"
    
    sv([opponentStateValueLabel, scoreTitleLabel, scoreValueLabel, boardView])
    scoreTitleLabel.left(20)
    scoreTitleLabel.Bottom == boardView.Top - 40
    scoreValueLabel.CenterY == scoreTitleLabel.CenterY
    scoreValueLabel.Left == scoreTitleLabel.Right + 5
    opponentStateValueLabel.left(20).Bottom == scoreTitleLabel.Top - 20
    
    boardView
      .size(GameboardOfflineView.Constants.boardWidth)
      .centerInContainer()
  }
}
