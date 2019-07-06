//
//  VRVideoView.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/1/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Swifty360Player

/// Displays a video in 360º, uses device motion and gestures recognizers to nagivate throughout the video.
@objc public class VRVideoView: UIViewController {
    
    fileprivate var swifty360ViewController: Swifty360ViewController?
    fileprivate var customVideoURL: URL? = nil
    fileprivate var autoplay: Bool = false
    fileprivate var showFullScreenButton: Bool = true
    fileprivate var videoFrame: CGRect = .zero
    fileprivate(set) var videoPlayer: AVPlayer?
    
    // fileprivate var videoPlayerViewCenter: CGPoint = .zero
    
    /// Creates a VRVideoView object to display a video in 360º with the provided information.
    ///
    /// - Parameters:
    ///   - url: video URL to display in the view.
    ///   - frame: display position and size to display the video in.
    ///   - autoPlay: determines whether or not the video should start playing automatically. Defaults to `true`.
    @objc public init(show url: URL, in frame: CGRect, autoPlay: Bool = true, showFullScreenButton: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.customVideoURL = url
        self.videoFrame = frame
        self.autoplay = autoPlay
        self.showFullScreenButton = showFullScreenButton
        self.view.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swifty360ViewController?.view.frame = self.view.bounds
    }
    
    @objc public func shouldHideTransitionView() -> Bool {
        return true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let url = customVideoURL else { return }
        videoPlayer = AVPlayer(url: url)
        guard let videoPlayer = videoPlayer else { return }
        
        let motionManager = Swifty360MotionManager.shared
        swifty360ViewController = Swifty360ViewController(withAVPlayer: videoPlayer,
                                                          motionManager: motionManager)
        
        if let swifty360ViewController = swifty360ViewController {
            if showFullScreenButton {
                addDefaultFullScreenButton(on: swifty360ViewController.view)
            }
            
            addChild(swifty360ViewController)
            view.addSubview(swifty360ViewController.view)
            swifty360ViewController.didMove(toParent: self)
        }
        
        if autoplay {
            videoPlayer.play()
        }
    }
    
    @objc private func addDefaultFullScreenButton(on view: UIView) {
        var isFullScreen = false
        _ = FullScreenButton(view: view, handler: { _ in
            if isFullScreen {
                self.undoFullScreen(animated: true, duration: 0.3)
            } else {
                self.fullScreen(animated: true, duration: 0.3)
            }
            isFullScreen.toggle()
        })
    }
    
    // FIXME: test + fix this function. Right now must be called after this view controller appears
    //        and some custom constraints are not working propertly.
    // TODO: expose this interface when issues are solved.
    @objc private func addFullScreenButton(
        appearance: FullScreenButton.Appearance = .dark,
        background: FullScreenButton.Background = .vibrant,
        hPosition: FullScreenButton.HPosition = .left,
        vPosition: FullScreenButton.VPosition = .top,
        isFullScreen: Bool = false) {
        
        guard let _view = swifty360ViewController?.view else { return }
        var _isFullScreen = isFullScreen
        _ = FullScreenButton(view: _view, handler: { (_) in
            if _isFullScreen {
                self.undoFullScreen(animated: true, duration: 0.3)
            } else {
                self.fullScreen(animated: true, duration: 0.3)
            }
            _isFullScreen.toggle()
        }, appearance: appearance, background: background, hPosition: hPosition, vPosition: vPosition)
        _view.layoutIfNeeded()
        _view.setNeedsDisplay()
    }
    
    // MARK: - Convenience methods.
    
    @objc public func play() {
        videoPlayer?.play()
    }
    
    @objc public func pause() {
        videoPlayer?.pause()
    }
    
    /// Rotates the `view` by the given angle.
    ///
    /// - Parameter angle: Must be a floating point value [in Radians].
    @objc public func rotate(by angle: Float) {
        let _angle = CGFloat(angle)
        view.transform = CGAffineTransform(rotationAngle: _angle)
    }

    /// Rotates the `view` to the given `RotationMode`
    ///
    /// - Parameters:
    ///   - mode: mode to rotate the view.
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func rotate(_ mode: RotationMode, animated: Bool, duration: Double) {
        let _duration = animated ? duration : 0.0
        let _angle = CGFloat(angle(for: mode))
        UIView.animate(withDuration: _duration) {
            self.view.transform = CGAffineTransform(rotationAngle: _angle)
        }
    }
    
    /// Updates the given URL and "rebuils" the current view.
    ///
    /// - Parameter url: new url to update from.
    @objc public func update(url: URL) {
        customVideoURL = url
        
        let item = AVPlayerItem(url: url)
        videoPlayer?.replaceCurrentItem(with: item)
        
        if autoplay {
            videoPlayer?.play()
        }
    }
    
    /// Pause and set to `nil` the current video player.
    @objc public func stop() {
        videoPlayer?.replaceCurrentItem(with: nil)
    }
    
    /// Equivalent to "reloading" this view.
    ///
    /// Call this method if you'd like to "resume" a video that has been stopped using the `.stop()` method.
    @objc public func startOver() {
        viewWillAppear(false)
    }
    
    /// Sets the current video frame to fill the screen bounds.
    ///
    /// - Parameters:
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func fullScreen(animated: Bool, duration: Double) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // TODO: explore other ways (such as scaling) to perform this fullScreen in a
            //       more fluent way.
            
            // self.videoPlayerViewCenter = self.view.center
            self.view.frame = UIScreen.main.bounds
            // self.view.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            // let scalingX = UIScreen.main.bounds.width / self.view.frame.width
            // let scalingY = UIScreen.main.bounds.height / self.view.frame.height
            // self.view.transform = CGAffineTransform(scaleX: scalingX, y: scalingY)
            self.view.layoutSubviews()
        }, completion: nil)
    }
    
    
    /// Undo the current full screen, if any.
    ///
    /// This method sets the view frame to the original `frame` provided when creating this `VRVideoView`.
    ///
    /// - Parameters:
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func undoFullScreen(animated: Bool, duration: Double) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // self.view.transform = CGAffineTransform.identity
            // self.view.center = self.videoPlayerViewCenter
            self.view.frame = self.videoFrame
            self.view.layoutSubviews()
        }, completion: nil)
    }
}

// MARK: - Helper
@objc extension VRVideoView {
    /// Computes the angle for the given `RotationMode`
    ///
    /// - Parameter mode: position to rotate.
    /// - Returns: floating point representing the angle (in radians).
    ///            Remember iOS coordinate system is flipped,
    ///            also, positive values will lead to a counterclockwise rotation.
    @objc private func angle(for mode: RotationMode) -> Float {
        switch mode {
        case .right:
            return (90 * .pi) / 180
        case .left:
            return (270 * .pi) / 180
        case .down:
            return (180 * .pi) / 180
        case .up:
            return (360 * .pi) / 180
        }
    }
}
