//
//  UIView+showPressAnimation.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-15.
//

import UIKit

extension UIView{
    func showPressAnimation(_ completionBlock: @escaping () -> Void) {
          isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
            }) {  (done) in
                UIView.animate(withDuration: 0.1,
                               delay: 0,
                               options: .curveLinear,
                               animations: { [weak self] in
                                    self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }) { [weak self] (_) in
                    self?.isUserInteractionEnabled = true
                    completionBlock()
                }
            }
        }
}
