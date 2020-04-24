//
//  BoardTests.swift
//  Game2048Tests
//
//  Created by Dmitry on 22.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import XCTest
@testable import Game2048

class BoardTests: XCTestCase {
  func testInitialCellCount() {
    let board = Board(size: 4)
    
    XCTAssert(board.cells.count == 2)
    XCTAssert(filledPositionsCount(inside: board) == 2)
  }
  
  func testBoardSize() {
    let board4x4 = Board(size: 4)
    let board6x6 = Board(size: 6)
    
    XCTAssertEqual(board4x4.positions.count, 16)
    XCTAssertEqual(board6x6.positions.count, 36)
  }
  
  func testAddCell() {
    let board = Board(size: 4)
    let initialCellCount = board.cells.count
    board.addCell()
    
    XCTAssertEqual(board.cells.count, initialCellCount + 1)
    XCTAssertEqual(filledPositionsCount(inside: board), initialCellCount + 1)
  }
  
  func testRestart() {
    let board = Board(size: 4)
    let initialCellCount = board.cells.count
    board.addCell()
    board.restart()
    
    XCTAssertEqual(board.cells.count, initialCellCount)
    XCTAssertEqual(filledPositionsCount(inside: board), initialCellCount)
  }
  
  func testUndoStep() {
    let board = Board(size: 4)
    let initialPositions = board.positions
    _ = board.moveCells(positionKeyPath: \.section, compareBy: <, nextPositionStepper: -=)
    board.addCell()
    _ = board.moveCells(positionKeyPath: \.section, compareBy: <, nextPositionStepper: -=)
    board.addCell()
    let (firstRevertedMovements, firstLastCell) = board.undoStep()
    let (secondRevertedMovements, secondLastCell) = board.undoStep()
    
    XCTAssertNotNil(firstRevertedMovements)
    XCTAssertNotNil(secondRevertedMovements)
    XCTAssertNotNil(firstLastCell)
    XCTAssertNotNil(secondLastCell)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
    XCTAssertEqual(board.positions, initialPositions)
  }
  
  func testMergeTwoInRow() {
    
    // Generate initial cells with value 4 and positions at (0, 1) and (0, 2)
    var testPositions = [
      IndexPath(item: 1, section: 0),
      IndexPath(item: 2, section: 0)
    ]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in 1 },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    
    // move cells right
    let movements = board.moveCells(positionKeyPath: \.item, compareBy: >, nextPositionStepper: +=)
    
    XCTAssertEqual(movements.count, 2)
    XCTAssertEqual(board.cells.count, 1)
    XCTAssertEqual(board.cells[0].value, 8)
    XCTAssertEqual(filledPositionsCount(inside: board), 1)
  }
  
  func testMergeThreeInRow() {
    
    // Generate initial cells with value 4 and positions at (0, 0), (1, 0) and (2, 0)
    var testPositions = [
      IndexPath(item: 0, section: 0),
      IndexPath(item: 0, section: 1),
      IndexPath(item: 0, section: 2)
    ]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in 1 },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    board.addCell()
    // move cells down
    let movements = board.moveCells(positionKeyPath: \.section, compareBy: >, nextPositionStepper: +=)
    
    XCTAssertEqual(movements.count, 3)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(board.cells.reduce(0, { $0 + $1.value }), 12)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
  }
  
  func testMoveDifferentValuesInRow() {
    // Generate initial cells with value 2 at (2, 2) and with value 4 at (3, 2)
    var testPositions = [
      IndexPath(item: 2, section: 2),
      IndexPath(item: 2, section: 3)
    ]
    var testRandomValues = [0, 1]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in testRandomValues.remove(at: 0) },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    // move cells up
    let movements = board.moveCells(positionKeyPath: \.section, compareBy: <, nextPositionStepper: -=)
    
    XCTAssertEqual(movements.count, 2)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(board.cells.reduce(0, { $0 + $1.value }), 6)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
  }
  
  func testMoveLeft() {
    // Generate initial cells with value 2 at (2, 2) and with value 4 at (2, 3)
    var testPositions = [
      IndexPath(item: 2, section: 2),
      IndexPath(item: 3, section: 2)
    ]
    var testRandomValues = [0, 1]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in testRandomValues.remove(at: 0) },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    // move cells left
    let movements = board.moveCells(positionKeyPath: \.item, compareBy: <, nextPositionStepper: -=)
    
    XCTAssertEqual(movements.count, 2)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
    XCTAssertEqual(board.cells[0].position.item, 0)
    XCTAssertEqual(board.cells[0].position.section, 2)
    XCTAssertEqual(board.cells[1].position.item, 1)
    XCTAssertEqual(board.cells[1].position.section, 2)
  }
  
  func testMoveRight() {
    // Generate initial cells with value 2 at (2, 1) and with value 4 at (2, 3)
    var testPositions = [
      IndexPath(item: 1, section: 2),
      IndexPath(item: 3, section: 2)
    ]
    var testRandomValues = [0, 1]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in testRandomValues.remove(at: 0) },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    // move cells right
    let movements = board.moveCells(positionKeyPath: \.item, compareBy: >, nextPositionStepper: +=)
    
    XCTAssertEqual(movements.count, 1)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
    XCTAssertEqual(board.cells[0].position.item, 2)
    XCTAssertEqual(board.cells[0].position.section, 2)
    XCTAssertEqual(board.cells[1].position.item, 3)
    XCTAssertEqual(board.cells[1].position.section, 2)
  }
  
  func testMoveUp() {
    // Generate initial cells with value 2 at (1, 2) and with value 4 at (2, 2)
    var testPositions = [
      IndexPath(item: 2, section: 1),
      IndexPath(item: 2, section: 2)
    ]
    var testRandomValues = [0, 1]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in testRandomValues.remove(at: 0) },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    // move cells up
    let movements = board.moveCells(positionKeyPath: \.section, compareBy: <, nextPositionStepper: -=)
    
    XCTAssertEqual(movements.count, 2)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
    XCTAssertEqual(board.cells[0].position.item, 2)
    XCTAssertEqual(board.cells[0].position.section, 0)
    XCTAssertEqual(board.cells[1].position.item, 2)
    XCTAssertEqual(board.cells[1].position.section, 1)
  }
  
  func testMoveDown() {
    // Generate initial cells with value 2 at (1, 2) and with value 4 at (2, 2)
    var testPositions = [
      IndexPath(item: 2, section: 1),
      IndexPath(item: 2, section: 2)
    ]
    var testRandomValues = [0, 1]
    let board = Board(
      size: 4,
      randomCellValueGenerator: { _ in testRandomValues.remove(at: 0) },
      randomCellPositionGenerator: { _ in testPositions.remove(at: 0) }
    )
    // move cells down
    let movements = board.moveCells(positionKeyPath: \.section, compareBy: >, nextPositionStepper: +=)
    
    XCTAssertEqual(movements.count, 2)
    XCTAssertEqual(board.cells.count, 2)
    XCTAssertEqual(filledPositionsCount(inside: board), 2)
    XCTAssertEqual(board.cells[0].position.item, 2)
    XCTAssertEqual(board.cells[0].position.section, 2)
    XCTAssertEqual(board.cells[1].position.item, 2)
    XCTAssertEqual(board.cells[1].position.section, 3)
  }
  
  private func filledPositionsCount(inside board: Board) -> Int {
    board.positions
      .filter { $0.value != .empty }
      .count
  }
}
