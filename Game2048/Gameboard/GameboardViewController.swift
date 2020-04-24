//
//  GameboardViewController.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit

class GameboardViewController: UIViewController {
  private let viewModel: GameboardViewModel
  private let router: GameboardRouter
  private var gameboardView: GameboardView!
  private let cellWidth: CGFloat
  
  init(viewModel: GameboardViewModel, router: GameboardRouter) {
    self.viewModel = viewModel
    self.router = router
    self.cellWidth = GameboardView.Constants.boardWidth / CGFloat(viewModel.size)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    router.controller = self

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.viewModel.delegate = self
    }
  }
  
  private func setupView() {
    let view = GameboardView()
    view.undoButton.addTarget(self, action: #selector(onPressUndoButton), for: .touchUpInside)
    view.restartButton.addTarget(self, action: #selector(onRestart), for: .touchUpInside)
    
    let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
    directions.forEach { direction in
      let swipeGestureRecognizer = UISwipeGestureRecognizer(
        target: self,
        action: #selector(handleSwipe(_:))
      )
      swipeGestureRecognizer.direction = direction
      swipeGestureRecognizer.numberOfTouchesRequired = 1
      view.boardView.addGestureRecognizer(swipeGestureRecognizer)
    }
    view.dataSource = self
    self.view = view
    gameboardView = view
  }
  
  @objc private func onPressUndoButton() {
    viewModel.undo()
  }
  
  @objc private func onRestart() {
    gameboardView.clearCells(completion: {[weak self] in
      self?.viewModel.restart()
    })
  }
  
  @objc private func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
    guard recognizer.state == .ended else { return }
    switch recognizer.direction {
    case .left:
      viewModel.moveLeft()
    case .right:
      viewModel.moveRight()
    case .up:
      viewModel.moveUp()
    case .down:
      viewModel.moveDown()
    default:
      print("Unknown direction \(recognizer.direction)")
    }
  }
  
  private func handleFailedGameAlertResult(_ result: GameboardRouter.FailedGameAlertResult) {
    switch result {
    case .restart:
      onRestart()
    case .undoAction:
      viewModel.undo()
    }
  }
}

extension GameboardViewController: GameboardViewDataSource {
  func numberOfRows() -> Int {
    viewModel.size
  }
}

extension GameboardViewController: GameboardViewModelDelegate {
  func onGameComplete(withResult result: GameResult) {
    switch result {
    case .fail:
      router.openFailedGameAlert(complete: {[weak self] result in
        self?.handleFailedGameAlertResult(result)
      })
    case .win:
      return
    }
  }
  
  
  func viewModel(_: GameboardViewModel, insertCell cell: Board.Cell) {
    gameboardView.insertCellWithAnimation(value: cell.value, at: cell.position)
  }
  
  func viewModel(_ viewModel: GameboardViewModel, cellPositionsDidChangeWithMovements movements: [Movement]) {
    let destructiveMovements = movements.filter { $0 is DestructiveMovement }
    let moveAnimator = UIViewPropertyAnimator(
      duration: 0.2,
      dampingRatio: 0.8,
      animations: {
        self.gameboardView.scoreValueLabel.text = String(viewModel.score)
        movements.forEach {
          self.gameboardView.moveCell(
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
          self.gameboardView.removeCell(at: movement.to)
          self.gameboardView.updateCellValue(
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
        self.gameboardView.scoreValueLabel.text = String(viewModel.score)
        self.gameboardView.removeCell(at: removedCellPosition)
        movements[0..<pivot].forEach {
          self.gameboardView.moveCell(
            at: $0.to,
            to: $0.from,
            isDestructive: false
          )
        }
        
        // TODO: animation to-from
        movements[pivot...].forEach {
          let value = viewModel.cellValue(at: $0.from)
          self.gameboardView.insertCell(withValue: value, at: $0.from)
          self.gameboardView.updateCellValue(value, at: $0.to)
        }
      }
    )
    moveAnimator.startAnimation()
  }
}
