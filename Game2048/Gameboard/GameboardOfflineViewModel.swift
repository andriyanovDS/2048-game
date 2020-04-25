//
//  GameboardOfflineViewModel.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class GameboardOfflineViewModelImpl: GameboardViewModelImpl, GameboardOfflineViewModel {

  override func viewDidLoad() {
    board.setupRandomInitialCells()
    super.viewDidLoad()
  }
  
  func undo() {
    let (revertedMovements, lastCellPosition) = board.undoStep()
    guard let movements = revertedMovements, let cellPosition = lastCellPosition else {
      return
    }
    delegate?.viewModel(self, didUndoStepWithMovements: movements, andRemoveCellAtPosition: cellPosition)
  }
  
  override func moveRight() {
    super.moveRight()
    addRandomCell()
  }
  
  override func moveUp() {
    super.moveUp()
    addRandomCell()
  }
  
  override func moveLeft() {
    super.moveLeft()
    addRandomCell()
  }
  
  override func moveDown() {
    super.moveDown()
    addRandomCell()
  }
}

enum GameResult {
  case fail
  case win
}

enum UserActionDirection: String, Codable {
  case right
  case left
  case up
  case down
}

struct UserActionPayload: Codable {
  let action: UserActionDirection
}

protocol GameboardOfflineViewModel: GameboardViewModel {
  func undo()
}



