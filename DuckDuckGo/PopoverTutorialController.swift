//
//  PopoverTutorialController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Core

class PopoverTutorialController: UIViewController {

    enum Tutorial: String {

        case fireButton = "FireButton"
        case privacyGrade = "PrivacyGrade"

    }

    @IBOutlet weak var animatedConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowConstraint: NSLayoutConstraint!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var arrow: UIView!

    var completion: (() -> Void)!

    override func viewDidLoad() {
        message.adjustPlainTextLineHeight(1.2)
        configureBackground()
        configureArrow()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.animateCharacter()
    }

    @IBAction func onTapDismiss() {
        dismiss(animated: true, completion: completion)
    }

    func updateArrowOffset(_ offset: CGFloat) {
        guard arrowConstraint != nil else { return }
        arrowConstraint.constant = offset
    }

    private func configureBackground() {
        backgroundView.layer.cornerRadius = 5
    }

    private func configureArrow() {
        arrow.transform = CGAffineTransform(rotationAngle: 45 * .pi / 180)
        arrow.layer.cornerRadius = 3
    }

    private func animateCharacter() {
        animatedConstraint.constant = 18
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }

    static func showTutorial(_ tutorial: Tutorial, fromView anchorView: UIView, atPoint point: Point? = nil, usingViewController viewController: UIViewController, completion: @escaping () -> Void) {
        let controller = UIStoryboard(name: "PopoverTutorials", bundle: nil).instantiateViewController(withIdentifier: tutorial.rawValue) as! PopoverTutorialController
        PopoverTutorialBackgroundView.controller = controller
        controller.completion = completion
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = controller
        controller.popoverPresentationController?.popoverBackgroundViewClass = PopoverTutorialBackgroundView.self
        viewController.present(controller: controller, fromView: anchorView, atPoint: point)
    }

}

extension PopoverTutorialController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        completion()
    }

}


class PopoverTutorialBackgroundView: UIPopoverBackgroundView {

    weak static var controller: PopoverTutorialController?

    private var _arrowDirection: UIPopoverArrowDirection = .any
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return _arrowDirection
        }

        set {
            _arrowDirection = newValue
        }
    }

    private var _arrowOffset: CGFloat = 0
    override var arrowOffset: CGFloat {
        get {
            return _arrowOffset
        }

        set {
            _arrowOffset = newValue
            PopoverTutorialBackgroundView.controller?.updateArrowOffset(newValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear

        if let shadowColor = layer.shadowColor {
            let color = UIColor(cgColor: shadowColor)
            layer.shadowColor = UIColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0.6).cgColor
        }

    }

    required init?(coder aDecoder: NSCoder) {
        // should never get called
        fatalError("init(coder:) has not been implemented")
    }

    public override static func arrowBase() -> CGFloat {
        return 10
    }

    public override static func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    public override static func arrowHeight() -> CGFloat {
        return 0
    }

}
