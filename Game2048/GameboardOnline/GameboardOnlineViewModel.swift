//
//  GameboardOnlineViewModel.swift
//  Game2048
//
//  Created by Dmitry on 28.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

protocol GameboardOnlineViewModel: GameboardViewModel {
  func viewDidLoad(withState: BoardInitialState)
  func appendOpponentCell(_: SharedCell)
}

class GameboardOnlineViewModelImpl: GameboardViewModelImpl, GameboardOnlineViewModel {
  func viewDidLoad(withState state: BoardInitialState) {
    switch state {
    case .random:
      board.setupRandomInitialCells()
    case .predefined(let cells):
      cells.forEach { board.appendCell(
        Board.Cell(position: $0.position, value: $0.value)
      )}
    }
    super.viewDidLoad()
  }
  
  func appendOpponentCell(_ cell: SharedCell) {
    let cell = Board.Cell(position: cell.position, value: cell.value)
    board.appendCell(cell)
    delegate?.viewModel(self, insertCell: cell)
  }
}

enum BoardInitialState {
  case random
  case predefined(cells: [SharedCell])
}
