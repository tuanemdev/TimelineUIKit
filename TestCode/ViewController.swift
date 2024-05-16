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
    case one        = 1
    case five       = 5
    case ten        = 10
    case fifteen    = 15
    case thirty     = 30
    case sixty      = 60
    
    var blocksPerHour: Int {
        GapTime.sixty.rawValue / self.rawValue
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray.withAlphaComponent(0.5)
        
        let seekbarView = TimeSeekBarView()
        self.view.addSubview(seekbarView)
        seekbarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seekbarView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120),
            seekbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            seekbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            seekbarView.heightAnchor.constraint(equalToConstant: 96)
        ])
    }
}

final class TimeSeekBarView: UIView {
    // UIView
    private let scrollView: UIScrollView = .init()
    private let timelineView: TimelineView = .init()
    private let timeLabel: UILabel = .init()
    // Properties
    private let timeSpacer: CGFloat = 90
    private var gapTime: GapTime = .sixty
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
    
    // MARK: - Setup View
    private func setupView() {
        // Background Color
        self.backgroundColor = .clear
        
        // ScrollView
        self.addSubview(scrollView)
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
        timelineView.events = [(start: 9.0, end: 9.15), (start: 11.0, end: 11.5), (start: 18.0, end: 18.2)]
        timelineView.gapTime = gapTime
        scrollView.addSubview(timelineView)
        
        // Current time indicator
        let indicatorView = UIImageView()
        indicatorView.image = UIImage(named: "indicator_line")
        self.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 6),
            indicatorView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        let timeBorderView = UIView()
        timeBorderView.layer.cornerRadius = 12
        timeBorderView.backgroundColor = .orange
        self.addSubview(timeBorderView)
        timeBorderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeBorderView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            timeBorderView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeBorderView.widthAnchor.constraint(equalToConstant: 55),
            timeBorderView.heightAnchor.constraint(equalToConstant: 24)
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
        
        // Pinch Gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        scrollView.addGestureRecognizer(pinchGesture)
        
        let buttonTestOffset = UIButton()
        buttonTestOffset.setTitle("Offset", for: .normal)
        buttonTestOffset.addTarget(self, action: #selector(infoButtonPressed(_:)), for: .touchUpInside)
        buttonTestOffset.frame = CGRect(x: self.frame.width / 2, y: 400, width: 200, height: 200)
        self.addSubview(buttonTestOffset)
    }
    
    @objc
    private func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let scale: CGFloat = gesture.scale
        
        guard scale > 1.5 && scale < 0.8 else { return }
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
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return (hours, minutes, seconds)
    }
    
    private func formatTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Sửa lại duration: Set tối đa ví dụ 0.5 giây trong cả 1 ngày, duration tương ứng với quãng thời gian cần chạy
    func scrollToOffset(offset: Double) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                self.scrollView.contentOffset.x = offset
            }
        }
    }
    
    @objc
    private func infoButtonPressed(_ sender: UIButton) {
        scrollToOffset(offset: 1500)
    }
}

extension TimeSeekBarView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let timeOffset = scrollView.contentOffset.x / (timeSpacer * CGFloat(gapTime.blocksPerHour))
        let timeSeconds = Int(timeOffset * 3600)
        let (hours, minutes, seconds) = convertSecondsToHoursMinutesSeconds(seconds: timeSeconds)
        let timeString = formatTimeString(hours: hours, minutes: minutes, seconds: seconds)
        timeLabel.text = "\(timeString)"
    }
}

final class TimelineView: UIView {
    var events: [(start: CGFloat, end: CGFloat)] = []
    var extraWidth: CGFloat = 0.0
    var gapTime: GapTime = .sixty
    
    private let totalHours: CGFloat = 24.0
    private var totalBlocks: CGFloat { totalHours * CGFloat(gapTime.blocksPerHour) }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        
        let timeWidth = rect.width - extraWidth
        let height = rect.height
        let blockWidth = timeWidth / totalBlocks
        
        // Background color
        context.setFillColor(UIColor.rgb(0xF9FAFB).cgColor)
        context.fill(rect)
        
        // Draw event areas with gradient
        for event in events {
            let startX = event.start / totalHours * timeWidth + extraWidth / 2
            let endX = event.end / totalHours * timeWidth + extraWidth / 2
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
            
            let x = CGFloat(timeBlock) / totalBlocks * timeWidth + extraWidth / 2
            context.move(to: CGPoint(x: x, y: height * 0.4167))
            context.addLine(to: CGPoint(x: x, y: 0))
            context.strokePath()
            
            // Draw shorter markers for each hour, dividing into 6 parts
            let increment = blockWidth / 6.0
            for i in 1..<6 {
                if timeBlock == totalBlocks { break }
                
                let subX = x + CGFloat(i) * increment
                context.move(to: CGPoint(x: subX, y: height * 0.1))
                context.addLine(to: CGPoint(x: subX, y: 0))
                context.strokePath()
            }
            
            let timeFormat = timeBlock / CGFloat(gapTime.blocksPerHour)
            let timeString = String(format: "%05.2f", timeFormat)
            let timeWithMinute: String = convertToTimeString(timeString) ?? "Invalid"
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10.0, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let size = timeWithMinute.size(withAttributes: attributes)
            timeWithMinute.draw(at: CGPoint(x: x - size.width / 2, y: height - size.height - (height * 0.05)), withAttributes: attributes)
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
    
    private func convertToTimeString(_ timeString: String) -> String? {
        // Split the string into hours and fractional part
        let components = timeString.split(separator: ".")
        guard components.count == 2,
              let hours = Int(components[0]),
              let fraction = Int(components[1]) else {
            return nil
        }
        
        // Convert the fractional part to minutes
        let minutes = Int(Double("0.\(fraction)")! * 60)
        
        // Format the time string
        return String(format: "%02d:%02d", hours, minutes)
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
