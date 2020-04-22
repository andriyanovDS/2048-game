//
//  GameboardView.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class GameboardView: UIView {
  weak var dataSource: GameboardViewDataSource? {
    didSet { setupPositions() }
  }
  var boardStackView = UIStackView()
  let boardView = UIView()
  var cellViews: [IndexPath: [CellView]] = [:]
  let scoreValueLabel = UILabel()
  private let scoreTitleLabel = UILabel()
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  struct Constants {
    static let boardWidth: CGFloat = UIScreen.main.bounds.width - 40
  }
  
  func view(at indexPath: IndexPath) -> UIView {
    let rowView = boardStackView.arrangedSubviews[indexPath.section]
    guard let rowStackView = rowView as? UIStackView else {
      fatalError("Position \(indexPath) is out of range")
    }
    return rowStackView.arrangedSubviews[indexPath.item]
  }
  
  func insertCell(withValue value: Int, at indexPath: IndexPath) {
    let cell = CellView()
    cell.updateValue(value)
    cell.alpha = 0.5
    cellViews[indexPath] = [cell]
    let positionView = view(at: IndexPath(item: 0, section: 0))
    boardView.sv(cell)
    let viewOrigin = translate(position: indexPath)
    cell
      .width(positionView.bounds.width)
      .height(positionView.bounds.height)
    let transformTranslate = CGAffineTransform.identity
      .translatedBy(x: viewOrigin.x + 5, y: viewOrigin.y + 5)
    let transform = transformTranslate
      .scaledBy(x: 0.5, y: 0.5)
    cell.transform = transform
    UIView.animate(withDuration: 0.2, animations: {
      cell.alpha = 1
      cell.transform = transformTranslate
    })
  }
  
  func updateCellValue(_ value: Int, at indexPath: IndexPath) {
    guard let cell = cellViews[indexPath] else { return }
    cell.first?.updateValue(value)
  }
  
  func moveCell(at indexPath: IndexPath, to: IndexPath, isDestructive: Bool) {
    guard let cells = cellViews[indexPath] else { return }
    let nextPosition = translate(position: to)
    if !isDestructive {
      cellViews[indexPath] = nil
      cellViews[to] = cells
    } else {
      cellViews[to]?.append(contentsOf: cells)
    }
    cells.first?.transform = CGAffineTransform(
      translationX: nextPosition.x + 5,
      y: nextPosition.y + 5
    )
  }
  
  func removeCell(at indexPath: IndexPath) {
    guard var cells = cellViews[indexPath] else { return }
    let lastCell = cells.remove(at: cells.index(before: cells.endIndex - 1))
    lastCell.removeFromSuperview()
    cellViews[indexPath] = cells
  }
  
  private func translate(position: IndexPath) -> CGPoint {
    let positionView = view(at: position)
    return positionView.convert(CGPoint.zero, to: boardStackView)
  }
  
  private func setupPositions() {
    guard let dataSource = self.dataSource else { return }
    let numberOfRows = dataSource.numberOfRows()
    boardStackView.axis = .vertical
    boardStackView.distribution = .fillEqually
    boardStackView.spacing = 5
    
    for _ in 0..<numberOfRows {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.spacing = 5
      stackView.distribution = .fillEqually
      for _ in 0..<numberOfRows {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 10
        stackView.addArrangedSubview(view)
      }
      boardStackView.addArrangedSubview(stackView)
    }
    
    boardView.sv(boardStackView)
    boardStackView.left(5).top(5).bottom(5).right(5)
  }
  
  private func setupView() {
    backgroundColor = .systemGray6
    boardView.backgroundColor = .systemGray2
    boardView.layer.cornerRadius = 10
    
    scoreTitleLabel.textColor = .label
    scoreTitleLabel.text = "Score:"
    scoreTitleLabel.font = .systemFont(ofSize: 40)
    
    scoreValueLabel.textColor = .label
    scoreValueLabel.text = "0"
    scoreValueLabel.font = .systemFont(ofSize: 40)
    
    sv([scoreTitleLabel, scoreValueLabel, boardView])
    scoreTitleLabel.left(20)
    scoreTitleLabel.Bottom == boardView.Top - 40
    scoreValueLabel.CenterY == scoreTitleLabel.CenterY
    scoreValueLabel.Left == scoreTitleLabel.Right + 5
    boardView
      .size(Constants.boardWidth)
      .centerInContainer()
  }
}

protocol GameboardViewDataSource: class {
  func numberOfRows() -> Int
}
