//
//  ViewController.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 14/5/24.
//

import UIKit

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

// Minute
enum GapTime: Int, CaseIterable {
    /* Case                 //  blocksPerHour */
    case one        = 1     //      60
    case five       = 5     //      12
    case ten        = 10    //      6
    case fifteen    = 15    //      4
    case thirty     = 30    //      2
    case sixty      = 60    //      1
    
    var blocksPerHour: Int {
        GapTime.sixty.rawValue / self.rawValue
    }
}

enum TimelineMode {
    case explore
    case download
}

class ViewController: UIViewController {
    
    private var testMode: TimelineMode = .explore
    var seekbarView: TimeSeekBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray.withAlphaComponent(0.5)
        
        seekbarView = TimeSeekBarView()
        self.view.addSubview(seekbarView)
        seekbarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seekbarView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120),
            seekbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            seekbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            seekbarView.heightAnchor.constraint(equalToConstant: 96)
        ])
        
        // MARK: - TEST
        let buttonTestOffset = UIButton()
        buttonTestOffset.setTitle("Offset", for: .normal)
        buttonTestOffset.addTarget(self, action: #selector(infoButtonPressed(_:)), for: .touchUpInside)
        buttonTestOffset.frame = CGRect(x: 20, y: 400, width: 100, height: 100)
        self.view.addSubview(buttonTestOffset)
        
        let changeMode = UIButton()
        changeMode.setTitle("Mode", for: .normal)
        changeMode.addTarget(self, action: #selector(changeMode(_:)), for: .touchUpInside)
        changeMode.frame = CGRect(x: self.view.frame.width / 2 + 20, y: 400, width: 100, height: 100)
        self.view.addSubview(changeMode)
    }
    
    @objc
    private func infoButtonPressed(_ sender: UIButton) {
        seekbarView.scrollToTimestamp(1500)
    }
    
    @objc
    private func changeMode(_ sender: UIButton) {
        if testMode == .explore {
            testMode = .download
        } else {
            testMode = .explore
        }
        
        seekbarView.setTimeline(to: testMode)
    }
}

final class TimeSeekBarView: UIView {
    // UIView
    private let scrollView: UIScrollView = .init()
    private let timelineView: TimelineView = .init()
    private let timeView: TimeView = .init()
    private let indicatorView: UIImageView = .init()
    // Properties
    private let timeSpacer: CGFloat = 90
    private var gapTime: GapTime = .sixty
    private var mode: TimelineMode = .explore {
        didSet { updateUIForTimelineMode() }
    }
    private var extraWidth: CGFloat { self.frame.width }
    
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
        timelineView.extraWidth = extraWidth
        scrollView.contentSize = timelineView.frame.size
    }
    
    // MARK: - Method
    func scrollToTimestamp(_ time: TimeInterval) {
        let seconds = secondsSinceBeginningOfDay(from: time)
        let offset = offsetFromSeconds(TimeInterval(seconds))
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    func setTimeline(to mode: TimelineMode) {
        self.mode = mode
    }
    
    private func updateUIForTimelineMode() {
        timeView.isHidden = mode == .download
        indicatorView.isHidden = mode == .download
        timelineView.setTimeline(to: mode)
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
        
        // Example event times (9:00-10:00 and 11:00-12:00)
        timelineView.events = [
            (start: 1.0, end: 1.05),
            (start: 9.0, end: 9.15),
            (start: 11.0, end: 11.5),
            (start: 18.0, end: 18.2)
        ]
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
        scrollView.contentSize = timelineView.frame.size
        timelineView.setNeedsDisplay()
        self.layoutIfNeeded()
    }
    
    private func convertSecondsToHoursMinutesSeconds(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = seconds / 3_600
        let minutes = (seconds % 3_600) / 60
        let seconds = seconds % 60
        return (hours, minutes, seconds)
    }
    
    private func formatTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func secondsFromOffset(_ offset: Double) -> Int {
        let timeOffset = offset / (timeSpacer * CGFloat(gapTime.blocksPerHour))
        let timeSeconds = Int(timeOffset * 3_600)
        return timeSeconds
    }
    
    private func offsetFromSeconds(_ seconds: TimeInterval) -> Double {
        return seconds / 3_600 * (timeSpacer * CGFloat(gapTime.blocksPerHour))
    }
    
    private func secondsSinceBeginningOfDay(from unixTimestamp: TimeInterval) -> Int {
        // Convert Unix timestamp to Date
        let date = Date(timeIntervalSince1970: unixTimestamp)
        // Get the current calendar
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        // Extract hour, minute, and second components from the date
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        // Calculate total seconds since beginning of the day
        let secondsSinceStartOfDay = (components.hour ?? 0) * 3_600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
        
        return secondsSinceStartOfDay
    }
}

extension TimeSeekBarView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let timeSeconds = secondsFromOffset(offset)
        let (hours, minutes, seconds) = convertSecondsToHoursMinutesSeconds(seconds: timeSeconds)
        let timeString = formatTimeString(hours: hours, minutes: minutes, seconds: seconds)
        timeView.updateTime(timeString)
    }
}

final class TimelineView: UIView {
    var events: [(start: CGFloat, end: CGFloat)] = []
    var extraWidth: CGFloat = 0.0
    var gapTime: GapTime = .sixty
    
    private let totalHours: Int = 24
    private var totalBlocks: Int { totalHours * gapTime.blocksPerHour }
    
    private var startHandle: UIView!
    private var endHandle: UIView!
    private var startHandleCenterX: NSLayoutConstraint!
    private var endHandleCenterX: NSLayoutConstraint!
    private var selectionOverlay: UIView!
    private var startTimeView: TimeView = .init()
    private var endTimeView: TimeView = .init()
    
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
    func setTimeline(to mode: TimelineMode) {
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
            let startX = event.start / CGFloat(totalHours) * timeWidth + extraWidth / 2
            let endX = event.end / CGFloat(totalHours) * timeWidth + extraWidth / 2
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
        startTimeView.updateTime(String(format: "%05.2f", startX))
        
        let endX = endHandle.frame.midX
        endTimeView.frame = CGRect(x: endX - 27.5, y: frame.height + 8, width: 55, height: 24)
        endTimeView.updateTime(String(format: "%05.2f", endX))
    }
}

final class TimeView: UIView {
    private let timeBorderView = UIView()
    private let timeLabel = UILabel()
    
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
        timeBorderView.layer.cornerRadius = self.frame.height / 2
    }
    
    private func setupView() {
        timeBorderView.backgroundColor = .orange
        self.addSubview(timeBorderView)
        timeBorderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeBorderView.topAnchor.constraint(equalTo: self.topAnchor),
            timeBorderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            timeBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timeBorderView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
        
        timeLabel.text = "00:00:00"
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .semibold)
        timeBorderView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: timeBorderView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: timeBorderView.centerYAnchor)
        ])
    }
    
    func updateTime(_ value: String) {
        timeLabel.text = value
    }
}

// Extension này VNPT có sẵn, copy sang cho giống
extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    static func rgb(_ rgb: Int) -> UIColor {
        return UIColor(
            r: (rgb >> 16) & 0xFF,
            g: (rgb >> 8) & 0xFF,
            b: rgb & 0xFF
        )
    }
    
    static func rgba(_ rgba: Int) -> UIColor { //A-R-G-B
        return UIColor(
            r: (rgba >> 16) & 0xFF,
            g: (rgba >> 8) & 0xFF,
            b: rgba & 0xFF,
            a: (rgba >> 24) & 0xFF
        )
    }
    
    static func color(hexString: String?) -> UIColor {
        guard let hexString = hexString else {
            return .black
        }
        var rgbaValue: UInt64 = 0
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        scanner.scanHexInt64(&rgbaValue)
        return hexString.count > 7 ? UIColor.rgba(Int(rgbaValue)) : UIColor.rgb(Int(rgbaValue))
    }
}
