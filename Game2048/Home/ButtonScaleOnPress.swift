//
//  ButtonScaleOnPress.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 25.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit

class ButtonScaleOnPress: UIButton {
  private let animationDuration = 0.2
  private var isAnimationInProgress = false

  override var isHighlighted: Bool {
    willSet (nextValue) {
      if !nextValue || isAnimationInProgress {
        return
      }
      isAnimationInProgress = true
      startAnimation(isHighlighted: true, onComplete: {
        self.startAnimation(isHighlighted: false, onComplete: {
          self.isAnimationInProgress = false
        })
      })
    }
  }
  private func startAnimation(isHighlighted: Bool, onComplete: @escaping () -> Void) {
    UIView.animate(
      withDuration: animationDuration,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.75,
      options: .allowUserInteraction,
      animations: {
        if isHighlighted {
          self.alpha = 0.7
          self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        } else {
          self.alpha = 1
          self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    },
      completion: { _ in onComplete() }
    )
  }
}
