//
//  FullScreenButton.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/4/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation
import UIKit

@objc public class FullScreenButton: UIButton {

    /// View to present the button on top of.
    @objc weak var view: UIView?
    private var appearance: Appearance = .light
    private var background: Background = .vibrant
    private var hPosition: HPosition = .left
    private var vPosition: VPosition = .top
    
    /// Full screen action.
    /// This closure gets called when the button gets touched (when firing `.touchUpInside` event).
    var handler: ((FullScreenButton) -> Void)?
    
    @objc required init(view: UIView, handler: ((FullScreenButton) -> Void)? = nil) {
        self.view = view
        self.handler = handler
        super.init(frame: .init(x: 20, y: 10, width: 30, height: 30))
        
        self.view?.addSubview(self)
        self.view?.bringSubviewToFront(self)
        prepareButton()
        self.addTarget(self, action: #selector(perform(action:)), for: .touchUpInside)
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func perform(action: FullScreenButton) {
        if let handler = action.handler {
            handler(self)
        }
    }
    
    @objc private func prepareButton() {
        // TODO: implement
    }
}
