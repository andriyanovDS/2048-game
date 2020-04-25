//
//  Board.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class Board {
  typealias RandomValueGenerator = (ClosedRange<Int>) -> Int
  typealias RandomPositionGenerator = ([IndexPath]) -> IndexPath
  
  let size: Int
  private(set) var positions: [IndexPath: PositionValue] = [:]
  private(set) var cells: [Cell] = []
  private var emptyPositions: [IndexPath] {
    positions.keys.filter { key in
      positions[key] == .empty
    }
  }
  private var stepsHistory: [[Movement]] = []
  private let randomCellValueGenerator: RandomValueGenerator
  private let randomCellPositionGenerator: RandomPositionGenerator
  
  private struct Constants {
    static let initialCellCount: Int = 2
  }
  
  init(
    size: Int,
    randomCellValueGenerator: @escaping RandomValueGenerator = Int.random,
    randomCellPositionGenerator: @escaping RandomPositionGenerator = { $0[Int.random(in: 0...$0.endIndex - 1)] }
  ) {
    self.size = size
    self.randomCellPositionGenerator = randomCellPositionGenerator
    self.randomCellValueGenerator = randomCellValueGenerator
    for index in 0..<size * size {
      let key = IndexPath(item: index/size, section: index % size)
      positions[key] = .empty
    }
  }
  
  func setupRandomInitialCells() {
    Array(0..<Constants.initialCellCount).forEach { _ in addCell() }
  }
  
  func appendCell(_ cell: Cell) {
    positions[cell.position] = .filled(cell: cell)
    self.cells.append(cell)
  }
  
  func restart() {
    positions.keys.forEach { positions[$0] = .empty }
    cells.removeAll()
    stepsHistory.removeAll()
    Array(0..<Constants.initialCellCount).forEach { _ in addCell() }
  }
  
  func undoStep() -> (revertedMovements: ReversedCollection<[Movement]>?, lastInsertedCellPosition: IndexPath?) {    
    guard let movements = stepsHistory.popLast() else {
      return (nil, nil)
    }
    
    let lastCell = cells.popLast()
    let reversedMovements = movements.reversed()
    
    if let cell = lastCell {
      positions[cell.position] = .empty
    }
    
    reversedMovements.forEach { movement in
      let cell = positions[movement.to]
      
      if movement is DefaultMovement {
        positions[movement.from] = cell
        positions[movement.to] = .empty
      }
      switch cell {
      case .filled(let cellAtPosition) where movement is DestructiveMovement:
        cellAtPosition.undoMerge()
        let removedCell = cellAtPosition.copy()
        removedCell.position = movement.from
        cells.insert(removedCell, at: (movement as! DestructiveMovement).removedAt)
        positions[movement.from] = .filled(cell: removedCell)
      case .filled(let cellAtPosition) where movement is DefaultMovement:
        cellAtPosition.position = movement.from
      default: break
      }
    }
    return (reversedMovements, lastCell?.position)
  }
  
  @discardableResult
  func addCell() -> Cell {
    let cell = Cell(
      emptyPositions: emptyPositions,
      randomCellValueGenerator: randomCellValueGenerator,
      randomCellPositionGenerator: randomCellPositionGenerator
    )
    positions[cell.position] = .filled(cell: cell)
    cells.append(cell)
    return cell
  }
  
  func moveCells(
    positionKeyPath: WritableKeyPath<IndexPath, Int>,
    compareBy: (Int, Int) -> Bool,
    nextPositionStepper: (inout Int, Int) -> Void
  ) -> [Movement] {
    var movements: [Movement] = []
    var mergedCells: Set<Cell> = []
    let sortedCells = cells.sorted(by: {
      compareBy($0.position[keyPath: positionKeyPath], $1.position[keyPath: positionKeyPath])
    })
    for cell in sortedCells {
      let currentPosition = cell.position
      var steps: [IndexPath] = []
      findNextPosition(
        for: currentPosition,
        keyPath: positionKeyPath,
        nextPositionStepper: nextPositionStepper,
        steps: &steps
      )
      guard let nextPosition = steps.last else { continue }
      let cellAtNextPosition = positions[nextPosition]
      
      switch cellAtNextPosition {
      case .filled(let nextCell):
        if nextCell.isMargePossible(with: cell) && !mergedCells.contains(nextCell) {
          let removedAt = mergeCell(cell, at: currentPosition, withCell: nextCell)
          mergedCells.insert(nextCell)
          movements.append(DestructiveMovement(from: currentPosition, to: nextPosition, removedAt: removedAt))
          continue
        }
        if steps.count < 2 { continue }
        let stepDownPosition = steps[steps.index(before: steps.endIndex - 1)]
        if positions[stepDownPosition] == .empty {
          moveCell(cell, from: currentPosition, to: stepDownPosition)
          movements.append(DefaultMovement(from: currentPosition, to: stepDownPosition))
        }
      case .empty:
        moveCell(cell, from: currentPosition, to: nextPosition)
        movements.append(DefaultMovement(from: currentPosition, to: nextPosition))
      default: continue
      }
    }
    if !(cells.count == size*size && movements.isEmpty) {
      stepsHistory.append(movements)
    }
    return movements
  }
  
  private func findNextPosition(
    for indexPath: IndexPath,
    keyPath: WritableKeyPath<IndexPath, Int>,
    nextPositionStepper: (inout Int, Int) -> Void,
    steps: inout [IndexPath]
  ) {
    var nextPosition = indexPath
    nextPositionStepper(&nextPosition[keyPath: keyPath], 1)
    if nextPosition[keyPath: keyPath] < 0 || nextPosition[keyPath: keyPath] == size {
      return
    }
    if positions[nextPosition] == .empty {
      steps.append(nextPosition)
      return findNextPosition(
        for: nextPosition,
        keyPath: keyPath,
        nextPositionStepper: nextPositionStepper,
        steps: &steps
      )
    }
    steps.append(nextPosition)
  }
  
  private func mergeCell(
    _ cell: Cell,
    at position: IndexPath,
    withCell mergedCell: Cell
  ) -> Int {
    mergedCell.merge(with: cell)
    positions[position] = .empty
    let index = cells.firstIndex(of: cell)!
    cells.remove(at: index)
    return index
  }
  
  private func moveCell(
    _ cell: Cell,
    from currentPosition: IndexPath,
    to nextPosition: IndexPath
  ) {
    cell.position = nextPosition
    positions[currentPosition] = .empty
    positions[nextPosition] = .filled(cell: cell)
  }
}

protocol Movement {
  var from: IndexPath { get }
  var to: IndexPath { get }
}

struct DefaultMovement: Movement, Equatable {
  let from: IndexPath
  let to: IndexPath
}

struct DestructiveMovement: Movement, Equatable {
  let from: IndexPath
  let to: IndexPath
  let removedAt: Int
}

extension Board {
  class Cell: Equatable, Hashable, CustomDebugStringConvertible {
    private(set) var value: Int
    var position: IndexPath
    var debugDescription: String {
      "Cell value: \(value) at position: \(position)"
    }
    
    init(
      emptyPositions: [IndexPath],
      randomCellValueGenerator: RandomValueGenerator,
      randomCellPositionGenerator: RandomPositionGenerator
    ) {
      self.value = randomCellValueGenerator(0...9) == 1
        ? 4
        : 2
      self.position = randomCellPositionGenerator(emptyPositions)
    }
    
    init(position: IndexPath, value: Int) {
      self.value = value
      self.position = position
    }
    
    func undoMerge() {
      value /= 2
    }
    
    func isMargePossible(with cell: Cell) -> Bool {
      return cell.value == value
    }
    
    func merge(with cell: Cell) {
      value += cell.value
    }
    
    static func == (lhs: Cell, rhs: Cell) -> Bool {
      return lhs.value == rhs.value && lhs.position == rhs.position
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(value)
      hasher.combine(position)
    }
    
    func copy() -> Cell {
      Cell(position: position, value: value)
    }
  }
  
  enum PositionValue: Equatable {
    case empty
    case filled(cell: Cell)
  }
}
