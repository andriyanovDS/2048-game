//
//  GameboardViewConfigurator.swift
//  Game2048
//
//  Created by Dmitry on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class GameboardViewConfigurator {
  weak var delegate: GameboardViewConfiguratorDelegate?
  private let viewModel: GameboardViewModel
  private let view: GameboardConfiguredView
  
  init(viewModel: GameboardViewModel, view: GameboardConfiguredView) {
    self.viewModel = viewModel
    self.view = view
  }
}

extension GameboardViewConfigurator: BoardViewDataSource {
  func numberOfRows() -> Int {
    viewModel.size
  }
}

extension GameboardViewConfigurator: GameboardViewModelDelegate {
  func onGameComplete(withResult result: GameResult) {
    delegate?.onGameComplete(withResult: result)
  }
  
  
  func viewModel(_: GameboardViewModel, insertCell cell: Board.Cell) {
    view.boardView.insertCellWithAnimation(value: cell.value, at: cell.position)
  }
  
  func viewModel(_ viewModel: GameboardViewModel, cellPositionsDidChangeWithMovements movements: [Movement]) {
    let destructiveMovements = movements.filter { $0 is DestructiveMovement }
    let moveAnimator = UIViewPropertyAnimator(
      duration: 0.2,
      dampingRatio: 0.8,
      animations: {
        self.view.setScore(viewModel.score)
        movements.forEach {
          self.view.boardView.moveCell(
            at: $0.from,
            to: $0.to,
            isDestructive: $0 is DestructiveMovement
          )
        }
      }
    )
    if destructiveMovements.count > 0 {
      moveAnimator.addCompletion { _ in
        destructiveMovements.forEach { movement in
          self.view.boardView.removeCell(at: movement.to)
          self.view.boardView.updateCellValue(
            self.viewModel.cellValue(at: movement.to),
            at: movement.to
          )
        }
      }
    }
    moveAnimator.startAnimation()
  }
  
  func viewModel(
    _ viewModel: GameboardViewModel,
    didUndoStepWithMovements movements: ReversedCollection<[Movement]>,
    andRemoveCellAtPosition removedCellPosition: IndexPath
  ) {
    var movements = Array(movements)
    let pivot = movements.partition(by: { $0 is DestructiveMovement })
    let moveAnimator = UIViewPropertyAnimator(
      duration: 0.2,
      dampingRatio: 0.8,
      animations: {
        self.view.setScore(viewModel.score)
        self.view.boardView.removeCell(at: removedCellPosition)
        movements[0..<pivot].forEach {
          self.view.boardView.moveCell(
            at: $0.to,
            to: $0.from,
            isDestructive: false
          )
        }
        
        // TODO: animation to-from
        movements[pivot...].forEach {
          let value = viewModel.cellValue(at: $0.from)
          self.view.boardView.insertCell(withValue: value, at: $0.from)
          self.view.boardView.updateCellValue(value, at: $0.to)
        }
      }
    )
    moveAnimator.startAnimation()
  }
}

protocol GameboardConfiguredView: UIView {
  var boardView: BoardView { get }
  func setScore(_: Int)
}

protocol GameboardViewConfiguratorDelegate: class {
  func onGameComplete(withResult result: GameResult)
}

