//
//  BoardView.swift
//  Game2048
//
//  Created by Dmitry on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import Stevia

class BoardView: UIView {
  weak var dataSource: BoardViewDataSource?
  var boardStackView = UIStackView()
  private var cellViews: [IndexPath: [CellView]] = [:]
  
  struct Constants {
    static let boardWidth: CGFloat = UIScreen.main.bounds.width - 40
  }
  
  func parentViewDidLoad() {
    setupView()
    setupPositions()
  }
  
  func clearCells(completion: @escaping () -> Void) {
    let cells = cellViews.values.flatMap { $0 }
    UIView.animate(
      withDuration: 0.2,
      animations: {
        cells.forEach { cell in
          cell.alpha = 0
          cell.transform = cell.transform.scaledBy(x: 0.5, y: 0.5)
        }
    },
      completion: {[weak self] _ in
        cells.forEach { $0.removeFromSuperview() }
        self?.cellViews = [:]
        completion()
      }
    )
  }
  
  func view(at indexPath: IndexPath) -> UIView {
    let rowView = boardStackView.arrangedSubviews[indexPath.section]
    guard let rowStackView = rowView as? UIStackView else {
      fatalError("Position \(indexPath) is out of range")
    }
    return rowStackView.arrangedSubviews[indexPath.item]
  }
  
  @discardableResult
  func insertCell(withValue value: Int, at indexPath: IndexPath) -> CellView {
    let cell = CellView()
    cell.updateValue(value)
    cellViews[indexPath] = [cell]
    let positionView = view(at: IndexPath(item: 0, section: 0))
    sv(cell)
    let viewOrigin = translate(position: indexPath)
    cell
      .width(positionView.bounds.width)
      .height(positionView.bounds.height)
    cell.transform = CGAffineTransform(translationX: viewOrigin.x + 5, y: viewOrigin.y + 5)
    return cell
  }
  
  func insertCellWithAnimation(value: Int, at indexPath: IndexPath) {
    let cellView = insertCell(withValue: value, at: indexPath)
    let currentTransform = cellView.transform
    let transform = currentTransform
      .scaledBy(x: 0.5, y: 0.5)
    cellView.transform = transform
    cellView.alpha = 0.5
    UIView.animate(withDuration: 0.2, animations: {
      cellView.alpha = 1
      cellView.transform = currentTransform
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
    guard let lastCell = cells.popLast() else { return }
    lastCell.removeFromSuperview()
    cellViews[indexPath] = cells
  }
  
  private func translate(position: IndexPath) -> CGPoint {
    let positionView = view(at: position)
    return positionView.convert(CGPoint.zero, to: boardStackView)
  }
  
  func setupPositions() {
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
    
    sv(boardStackView)
    boardStackView.left(5).top(5).bottom(5).right(5)
  }
  
  private func setupView() {
    backgroundColor = .systemGray6
    backgroundColor = .systemGray2
    layer.cornerRadius = 10
  }
}

protocol BoardViewDataSource: class {
  func numberOfRows() -> Int
}
