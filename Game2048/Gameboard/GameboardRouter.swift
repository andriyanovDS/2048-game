//
//  GameboardRouter.swift
//  Game2048
//
//  Created by Dmitry on 23.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit


class GameboardRouter {
  weak var controller: UIViewController?
  
  func openFailedGameAlert(
    complete: @escaping (FailedGameAlertResult) -> Void
  ) {
    let restartAction = UIAlertAction(
      title: "Restart",
      style: .destructive,
      handler: { _ in complete(.restart) }
    )
    let undoAction = UIAlertAction(
      title: "Undo action",
      style: .default,
      handler: { _ in complete(.undoAction) }
    )
    
    let alertViewController = UIAlertController(
      title: "Ooops",
      message: "You failed... Would you like to restart game?",
      preferredStyle: .alert
    )
    alertViewController.addAction(undoAction)
    alertViewController.addAction(restartAction)
    controller?.present(alertViewController, animated: true, completion: nil)
  }
}

extension GameboardRouter {
  enum FailedGameAlertResult {
    case restart
    case undoAction
  }
}
