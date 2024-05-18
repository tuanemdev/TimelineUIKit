//
//  OHTimelineView.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 18/5/24.
//

import UIKit

final class OHTimelineView: UIView {
    var events: [OHTimelineEvent] = .init()
    var extraWidth: CGFloat = 0.0
    var gapTime: OHTimelineGapTime = .sixty
    
    private let totalHours: Int = 24
    private var totalBlocks: Int { totalHours * gapTime.blocksPerHour }
    
    private var startHandle: UIView!
    private var endHandle: UIView!
    private var startHandleCenterX: NSLayoutConstraint!
    private var endHandleCenterX: NSLayoutConstraint!
    private var selectionOverlay: UIView!
    private var startTimeView: OHTimeView = .init()
    private var endTimeView: OHTimeView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandles()
        setupSelectionOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHandles()
        setupSelectionOverlay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectionOverlay()
        updateTimeView()
    }
    
    // MARK: - function
    func setTimeline(to mode: OHTimelineMode) {
        startTimeView.isHidden = mode == .explore
        endTimeView.isHidden = mode == .explore
        startHandle.isHidden = mode == .explore
        endHandle.isHidden = mode == .explore
        selectionOverlay.isHidden = mode == .explore
    }
    
    // MARK: - Draw UI and private function
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        
        let timeWidth = rect.width - extraWidth
        let height = rect.height
        let blockWidth = timeWidth / CGFloat(totalBlocks)
        
        // Background color
        context.setFillColor(UIColor.rgb(0xF9FAFB).cgColor)
        context.fill(rect)
        
        // Draw event areas with gradient
        for event in events {
            let startX = CGFloat(event.startTime) / CGFloat(86_400) * timeWidth + extraWidth / 2
            let endX = CGFloat(event.endTime) / CGFloat(86_400) * timeWidth + extraWidth / 2
            let eventRect = CGRect(x: startX, y: 0, width: endX - startX, height: height)
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = eventRect
            gradientLayer.colors = [UIColor.systemMint.withAlphaComponent(0.5).cgColor, UIColor.white.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
            
            if let gradientImage = imageFromLayer(layer: gradientLayer) {
                context.draw(gradientImage.cgImage!, in: eventRect)
            }
        }
        
        // Draw hour markers and labels
        for timeBlock in stride(from: 0, to: totalBlocks + 1, by: 1) {
            context.setStrokeColor(UIColor.rgb(0x818A98).cgColor)
            context.setLineWidth(1)
            
            let location_x: CGFloat = CGFloat(timeBlock) / CGFloat(totalBlocks) * timeWidth + extraWidth / 2
            context.move(to: CGPoint(x: location_x, y: height * 0.4167))
            context.addLine(to: CGPoint(x: location_x, y: 0))
            context.strokePath()
            
            // Draw shorter markers for each hour, dividing into 6 parts
            let increment = blockWidth / 6.0
            for i in 1..<6 {
                if timeBlock == totalBlocks { break }
                
                let subX = location_x + CGFloat(i) * increment
                context.move(to: CGPoint(x: subX, y: height * 0.1))
                context.addLine(to: CGPoint(x: subX, y: 0))
                context.strokePath()
            }
            
            // label
            let timeWithMinute = convertBlockToTime(timeBlock, scale: gapTime.blocksPerHour)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10.0, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let size = timeWithMinute.size(withAttributes: attributes)
            timeWithMinute.draw(at: CGPoint(x: location_x - size.width / 2, y: height - size.height - (height * 0.05)), withAttributes: attributes)
        }
    }
    
    private func imageFromLayer(layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContext(layer.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func convertBlockToTime(_ block: Int, scale: Int) -> String {
        let hours = block / scale
        let minutes = (block % scale) * 60 / scale
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    // MARK: - Gap Selection
    private func setupHandles() {
        startHandle = createHandle()
        endHandle = createHandle()
        addSubview(startHandle)
        addSubview(endHandle)
        
        startHandleCenterX = startHandle.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: 300)
        endHandleCenterX = endHandle.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: 350)
        NSLayoutConstraint.activate([
            startHandle.topAnchor.constraint(equalTo: self.topAnchor),
            startHandle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            startHandle.widthAnchor.constraint(equalToConstant: 16),
            startHandleCenterX,
            
            endHandle.topAnchor.constraint(equalTo: self.topAnchor),
            endHandle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            endHandle.widthAnchor.constraint(equalToConstant: 16),
            endHandleCenterX
        ])
        
        let startPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        startHandle.addGestureRecognizer(startPanGesture)
        
        let endPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        endHandle.addGestureRecognizer(endPanGesture)
        
        addSubview(startTimeView)
        addSubview(endTimeView)
    }
    
    private func createHandle() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let divider = UIView()
        divider.backgroundColor = .orange
        container.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: container.topAnchor),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            divider.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        let handle = UIImageView(image: UIImage(named: "handle"))
        container.addSubview(handle)
        handle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            handle.widthAnchor.constraint(equalToConstant: 16),
            handle.heightAnchor.constraint(equalToConstant: 16),
            handle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            handle.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let handle = gesture.view else { return }
        let translation = gesture.translation(in: self)
        let newCenterX = handle.center.x + translation.x
        
        if handle == startHandle, newCenterX >= extraWidth/2 && newCenterX <= endHandle.center.x {
            startHandleCenterX.constant += translation.x
        }
        
        if handle == endHandle, newCenterX <= (self.bounds.width - extraWidth/2) && newCenterX >= startHandle.center.x {
            endHandleCenterX.constant += translation.x
        }
        
        gesture.setTranslation(.zero, in: self)
    }
    
    private func setupSelectionOverlay() {
        selectionOverlay = UIView()
        selectionOverlay.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionOverlay)
        sendSubviewToBack(selectionOverlay)
    }
    
    private func updateSelectionOverlay() {
        let startX = startHandle.frame.midX
        let endX = endHandle.frame.midX
        selectionOverlay.frame = CGRect(x: startX, y: 0, width: endX - startX, height: self.frame.height)
    }
    
    private func updateTimeView() {
        let startX = startHandle.frame.midX
        startTimeView.frame = CGRect(x: startX - 27.5, y: frame.height + 8, width: 55, height: 24)
        let startTimePos = secondsFromPosition(startX)
        let startHMS = OHTimelineUtils.convertSecondsToHoursMinutesSeconds(seconds: startTimePos)
        let startFormattedTime = OHTimelineUtils.formatTimeString(hours: startHMS.hours, minutes: startHMS.minutes, seconds: startHMS.seconds)
        startTimeView.updateTime(startFormattedTime)
        
        let endX = endHandle.frame.midX
        endTimeView.frame = CGRect(x: endX - 27.5, y: frame.height + 8, width: 55, height: 24)
        let endTimePos = secondsFromPosition(endX)
        let endHMS = OHTimelineUtils.convertSecondsToHoursMinutesSeconds(seconds: endTimePos)
        let endFormattedTime = OHTimelineUtils.formatTimeString(hours: endHMS.hours, minutes: endHMS.minutes, seconds: endHMS.seconds)
        endTimeView.updateTime(endFormattedTime)
    }
    
    // MARK: - Utils
    private func secondsFromPosition(_ position: Double) -> Int {
        let timePosition = (position - extraWidth/2) / (self.frame.size.width - extraWidth)
        let timeSeconds = Int(timePosition * 86_400)
        return timeSeconds
    }
}
