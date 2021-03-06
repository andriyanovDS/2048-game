//
//  GameboardViewModel.swift
//  Game2048
//
//  Created by Dmitry on 28.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class GameboardViewModelImpl: GameboardViewModel {
  weak var delegate: GameboardViewModelDelegate?
  var score: Int = 0
  var size: Int { board.size }
  var cells: [Board.Cell] { board.cells }
  let board: Board
  var isGameCompleted: Bool = false
  
  init(board: Board) {
    self.board = board
  }
  
  func viewDidLoad() {
    board.cells.forEach {
      delegate?.viewModel(self, insertCell: $0)
    }
  }
  
  func restart() {
    board.restart()
    board.cells.forEach {
      delegate?.viewModel(self, insertCell: $0)
    }
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
  
  func moveCells(moveAction: @autoclosure () -> [Movement]) {
    guard !isGameCompleted, let delegate = self.delegate else { return }
    let movements = moveAction()
    
    if board.cells.count == size * size && movements.isEmpty {
      delegate.onGameComplete(withResult: .fail)
      return
    }
    if !isGameCompleted && board.cells.contains(where: { $0.value == 2048 }) {
      isGameCompleted = true
      delegate.onGameComplete(withResult: .win)
    }
    
    updateScore(after: movements)
    delegate.viewModel(self, cellPositionsDidChangeWithMovements: movements)
  }
  
  func updateScore(after movements: [Movement]) {
    score += movements
      .filter { $0 is DestructiveMovement }
      .reduce(0, { result, movement -> Int in
        let cell = board.positions[movement.to]
        switch cell {
        case .filled(let cell):
          return result + cell.value
        default: return result
        }
      })
  }
  
  func addRandomCell() {
    let cell = board.addCell()
    delegate?.viewModel(self, insertCell: cell)
  }
}

protocol GameboardViewModel: class {
  var size: Int { get }
  var cells: [Board.Cell] { get }
  var score: Int { get }
  var delegate: GameboardViewModelDelegate? { get set }
  
  func viewDidLoad()
  func restart()
  func moveUp()
  func moveDown()
  func moveLeft()
  func moveRight()
  func addRandomCell()
  func cellValue(at: IndexPath) -> Int
}

protocol GameboardViewModelDelegate: class {
  func onGameComplete(withResult: GameResult)
  func viewModel(_: GameboardViewModel, insertCell: Board.Cell)
  func viewModel(_: GameboardViewModel, cellPositionsDidChangeWithMovements: [Movement])
  func viewModel(
    _: GameboardViewModel,
    didUndoStepWithMovements: ReversedCollection<[Movement]>,
    andRemoveCellAtPosition: IndexPath
  )
}
