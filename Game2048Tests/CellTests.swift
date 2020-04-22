//
//  CellTests.swift
//  Game2048Tests
//
//  Created by Dmitry on 22.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import XCTest
@testable import Game2048

class CellTests: XCTestCase {
  var fakeRandomPositionGenerator: (([IndexPath]) -> IndexPath)!
  
  override func setUp() {
    fakeRandomPositionGenerator = { $0[0] }
  }
  
  func testDebugDescription() {
    let cell = Board.Cell(
      emptyPositions: [IndexPath(item: 1, section: 1)],
      randomCellValueGenerator: { _ in 2 },
      randomCellPositionGenerator: fakeRandomPositionGenerator
    )
    let description = cell.debugDescription
    
    XCTAssert(description.contains(String(cell.value)))
    XCTAssert(description.contains("\(cell.position)"))
  }
  
  func testPosition() {
    let emptyPositions = [
      IndexPath(item: 1, section: 1),
      IndexPath(item: 1, section: 0)
    ]
    let cell = Board.Cell(
      emptyPositions: emptyPositions,
      randomCellValueGenerator: { _ in 2 },
      randomCellPositionGenerator: fakeRandomPositionGenerator
    )
    
    XCTAssert(emptyPositions.contains(cell.position))
  }
  
  func testIsMergePossible() {
    let emptyIndexPath = IndexPath(item: 1, section: 1)
    let cell = Board.Cell(
      emptyPositions: [emptyIndexPath],
      randomCellValueGenerator: { _ in 2 },
      randomCellPositionGenerator: fakeRandomPositionGenerator
    )
    let mergeCell = Board.Cell(
      emptyPositions: [IndexPath(item: 1, section: 0)],
      randomCellValueGenerator: { _ in 2 },
      randomCellPositionGenerator: fakeRandomPositionGenerator
    )
    
    XCTAssert(cell.isMargePossible(with: mergeCell))
  }
  
  func testMerge() {
    let cell = Board.Cell(
      emptyPositions: [IndexPath(item: 1, section: 1)],
      randomCellValueGenerator: { _ in 2 },
      randomCellPositionGenerator: fakeRandomPositionGenerator
    )
    let mergeCell = Board.Cell(
      emptyPositions: [IndexPath(item: 1, section: 0)],
      randomCellValueGenerator: { _ in 2 },
      randomCellPositionGenerator: fakeRandomPositionGenerator
    )
    
    cell.merge(with: mergeCell)
    XCTAssertEqual(cell.value, 4)
  }
}
