//
//  OHTimeSeekBarView.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 18/5/24.
//

import UIKit

// MARK: - Delegate
protocol OHTimeSeekBarViewDelegate: AnyObject {
    func timeSeekBarView(_ timeSeekBarView: OHTimeSeekBarView, endAt unixTimestamp: Int)
}

// MARK: - OHTimeSeekBarView
final class OHTimeSeekBarView: UIView {
    // UIView
    private let scrollView: UIScrollView = .init()
    private let timelineView: OHTimelineView = .init()
    private let timeView: OHTimeView = .init()
    private let indicatorView: UIImageView = .init()
    // Properties
    private let timeSpacer: CGFloat = 90
    private var gapTime: OHTimelineGapTime = .sixty
    private var mode: OHTimelineMode = .explore {
        didSet { updateUIForTimelineMode() }
    }
    private var extraWidth: CGFloat { self.frame.width }
    // To fix the discrepancy between the values of setContentOffset and scrollView.contentOffset in scrollViewDidScroll(_:)
    private var isProgrammaticScroll = false
    // Save current timeStamp
    private var timeIntervalSince1970ToMidnight: Int = 0
    private var timeIntervalSince00h00: Int = 0
    
    // MARK: - Delegate
    weak var delegate: OHTimeSeekBarViewDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = CGRect(
            x: 0,
            y: 0,
            width: CGFloat(gapTime.blocksPerHour) * 24 * timeSpacer + extraWidth,
            height: 48
        )
        timelineView.contentScaleFactor = 2
        timelineView.extraWidth = extraWidth
        scrollView.contentSize = timelineView.frame.size
    }
    
    // MARK: - Method
    func scrollToTimestamp(_ time: TimeInterval, animated: Bool = true) {
        let secondsSBoD = OHTimelineUtils.secondsSinceBeginningOfDay(from: time)
        let offset = offsetFromSeconds(TimeInterval(secondsSBoD))
        isProgrammaticScroll = true
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        // If not animated, reset the flag immediately
        if !animated { isProgrammaticScroll = false }
        // Update time label
        let (hours, minutes, seconds) = OHTimelineUtils.convertSecondsToHoursMinutesSeconds(seconds: secondsSBoD)
        let timeString = OHTimelineUtils.formatTimeString(hours: hours, minutes: minutes, seconds: seconds)
        timeView.updateTime(timeString)
        // Save current time
        timeIntervalSince1970ToMidnight = OHTimelineUtils.timeIntervalSince1970ToMidnight(from: time)
        timeIntervalSince00h00 = secondsSBoD
    }
    
    func setTimeline(to mode: OHTimelineMode) {
        self.mode = mode
    }
    
    func setupEvents(_ events: [OHTimelineEvent]) {
        timelineView.events = events
    }
    
    // MARK: - private function
    private func setupView() {
        // Background Color
        self.backgroundColor = .clear
        
        // ScrollView
        self.addSubview(scrollView)
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 48)
        ])
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        timelineView.gapTime = gapTime
        scrollView.addSubview(timelineView)
        
        // Current time indicator
        indicatorView.image = UIImage(named: "indicator_line")
        self.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 6),
            indicatorView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        self.addSubview(timeView)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            timeView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeView.widthAnchor.constraint(equalToConstant: 55),
            timeView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Pinch Gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        scrollView.addGestureRecognizer(pinchGesture)
        
        // Mode
        updateUIForTimelineMode()
    }
    
    private func updateUIForTimelineMode() {
        timeView.isHidden = mode == .download
        indicatorView.isHidden = mode == .download
        timelineView.setTimeline(to: mode)
    }
    
    @objc
    private func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let scale: CGFloat = gesture.scale
        
        guard scale > 1.5 || scale < 0.8 else { return }
        // Zoom In
        if scale > 1.5 {
            guard let previous = gapTime.previous() else { return }
            gapTime = previous
        }
        // Zoom Out
        if scale < 0.8 {
            guard let next = gapTime.next() else { return }
            gapTime = next
        }
        
        timelineView.frame.size.width = timeSpacer * 24 * CGFloat(gapTime.blocksPerHour) + extraWidth
        timelineView.gapTime = gapTime
        timelineView.setNeedsDisplay()
        scrollToTimestamp(Double(timeIntervalSince00h00), animated: false)
        scrollView.contentSize = timelineView.frame.size
    }
    
    // MARK: - Utils
    private func secondsFromOffset(_ offset: Double) -> Int {
        let timeOffset = offset / (timeSpacer * CGFloat(gapTime.blocksPerHour))
        let timeSeconds = Int(timeOffset * 3_600)
        return timeSeconds
    }
    
    private func offsetFromSeconds(_ seconds: TimeInterval) -> Double {
        return seconds * (timeSpacer * CGFloat(gapTime.blocksPerHour)) / 3_600
    }
}

// MARK: - UIScrollViewDelegate
extension OHTimeSeekBarView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isProgrammaticScroll else { return }
        let offset = scrollView.contentOffset.x
        let timeSeconds = secondsFromOffset(offset)
        let (hours, minutes, seconds) = OHTimelineUtils.convertSecondsToHoursMinutesSeconds(seconds: timeSeconds)
        let timeString = OHTimelineUtils.formatTimeString(hours: hours, minutes: minutes, seconds: seconds)
        timeView.updateTime(timeString)
        // Save current time
        timeIntervalSince00h00 = timeSeconds
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isProgrammaticScroll = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        scrollViewDidEndScrolling()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling()
    }
    
    private func scrollViewDidEndScrolling() {
        guard mode == .explore else { return }
        delegate?.timeSeekBarView(self, endAt: timeIntervalSince1970ToMidnight + timeIntervalSince00h00)
    }
}

// MARK: - CaseIterable - previous() && next()
fileprivate
extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    func previous() -> Self? {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let previous = all.index(before: idx)
        
        if previous < all.startIndex { return nil }
        return all[previous]
    }
    
    func next() -> Self? {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        
        if next == all.endIndex { return nil }
        return all[next]
    }
}
