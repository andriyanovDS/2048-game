//
//  GameboardViewModel.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class GameboardViewModelImpl: GameboardViewModel {
  let size: Int
  weak var delegate: GameboardViewModelDelegate? {
    didSet { onViewReady() }
  }
  var score: Int = 0
  private let board: Board
  private var isGameCompleted: Bool = false
  
  init(size: Int) {
    self.size = size
    self.board = Board(size: size)
  }
  
  func moveRight() {
    moveCells(moveAction: board.moveCells(
      positionKeyPath: \.item,
      compareBy: >,
      nextPositionStepper: +=
     ))
  }
  
  func moveUp() {
    moveCells(moveAction: board.moveCells(
      positionKeyPath: \.section,
      compareBy: <,
      nextPositionStepper: -=
    ))
  }
  
  func moveLeft() {
    moveCells(moveAction: board.moveCells(
      positionKeyPath: \.item,
      compareBy: <,
      nextPositionStepper: -=
    ))
  }
  
  func moveDown() {
    moveCells(moveAction: board.moveCells(
      positionKeyPath: \.section,
      compareBy: >,
      nextPositionStepper: +=
    ))
  }
  
  func cellValue(at indexPath: IndexPath) -> Int {
    let position = board.positions[indexPath]
    switch position {
    case .empty:
      fatalError("Cell should not be empty")
    case .filled(let cell):
      return cell.value
    default: fatalError("Unexpected position \(position.debugDescription)")
    }
  }
  
  private func moveCells(moveAction: @autoclosure () -> [Movement]) {
    guard let delegate = self.delegate else { return }
    let movements = moveAction()
    updateScore(after: movements)
    delegate.viewModel(self, cellPositionsDidChangeWithMovements: movements)
    let cell = board.addCell()
    delegate.viewModel(self, insertCell: cell)
    if board.cells.count == size * size {
      delegate.onGameComplete(withResult: .fail)
      return
    }
    if !isGameCompleted && board.cells.contains(where: { $0.value == 2048 }) {
      isGameCompleted = true
      delegate.onGameComplete(withResult: .win)
    }
  }
  
  private func updateScore(after movements: [Movement]) {
    score += movements
      .filter { $0.isDestructive }
      .reduce(0, { result, movement -> Int in
        let cell = board.positions[movement.to]
        switch cell {
        case .filled(let cell):
          return result + cell.value
        default: return result
        }
      })
  }
  
  private func onViewReady() {
    board.cells.forEach {
      delegate?.viewModel(self, insertCell: $0)
    }
  }
}

enum GameResult {
  case fail
  case win
}

protocol GameboardViewModel: class {
  var size: Int { get }
  var score: Int { get }
  var delegate: GameboardViewModelDelegate? { get set }
  
  func moveUp()
  func moveDown()
  func moveLeft()
  func moveRight()
  func cellValue(at: IndexPath) -> Int
}

protocol GameboardViewModelDelegate: class {
  func onGameComplete(withResult: GameResult)
  func viewModel(_: GameboardViewModel, insertCell: Board.Cell)
  func viewModel(_: GameboardViewModel, cellPositionsDidChangeWithMovements: [Movement])
}

