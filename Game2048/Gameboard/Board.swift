//
//  Board.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class Board {
  private let size: Int
  private(set) var positions: [IndexPath: PositionValue] = [:]
  private(set) var cells: [Cell] = []
  private var emptyPositions: [IndexPath] {
    positions.keys.filter { key in
      positions[key] == .empty
    }
  }
  
  private struct Constants {
    static let initialCellCount: Int = 2
  }
  
  init(size: Int) {
    self.size = size
    for index in 0..<size * size {
      let key = IndexPath(item: index/size, section: index % size)
      positions[key] = .empty
    }
    Array(0..<Constants.initialCellCount).forEach { _ in addCell() }
  }
  
  @discardableResult
  func addCell() -> Cell {
    let cell = Cell(emptyPositions: emptyPositions)
    positions[cell.position] = .filled(cell: cell)
    cells.append(cell)
    return cell
  }
  
  func findNextPosition(
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
          mergeCell(cell, at: currentPosition, withCell: nextCell)
          mergedCells.insert(nextCell)
          movements.append(Movement(from: currentPosition, to: nextPosition, isDestructive: true))
          continue
        }
        if steps.count < 2 { continue }
        let stepDownPosition = steps[steps.index(before: steps.endIndex - 1)]
        if positions[stepDownPosition] == .empty {
          moveCell(cell, from: currentPosition, to: stepDownPosition)
          movements.append(Movement(from: currentPosition, to: stepDownPosition, isDestructive: false))
        }
      case .empty:
        moveCell(cell, from: currentPosition, to: nextPosition)
        movements.append(Movement(from: currentPosition, to: nextPosition, isDestructive: false))
      default: continue
      }
    }
    return movements
  }
  
  private func mergeCell(
    _ cell: Cell,
    at position: IndexPath,
    withCell mergedCell: Cell
  ) {
    mergedCell.merge(with: cell)
    positions[position] = .empty
    cells.removeAll(where: { $0 == cell })
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

struct Movement {
  let from: IndexPath
  let to: IndexPath
  let isDestructive: Bool
}

extension Board {
  class Cell: Equatable, Hashable, CustomDebugStringConvertible {
    var value: Int
    var position: IndexPath
    var debugDescription: String {
      "Cell value: \(value) at position: \(position)"
    }
    
    init(emptyPositions: [IndexPath]) {
      self.value = Int.random(in: 0..<10) == 1
        ? 4
        : 2
      self.position = emptyPositions[Int.random(in: 0...emptyPositions.count - 1)]
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
  }
  
  enum PositionValue: Equatable {
    case empty
    case filled(cell: Cell)
  }
}
