//
//  ViewController.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 14/5/24.
//

import UIKit

// Minute
enum GapTime {
    case one
    case five
    case ten
    case fifteen
    case thirty
    case sixty
}

class ViewController: UIViewController {
    
    private let timeSpacer: CGFloat = 100
    private var extraWidth: CGFloat { self.view.frame.width }
    private let timeLabel: UILabel = .init()
    private let scrollView: UIScrollView = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 80)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        // 24h * timeSpacer
        let timelineView = TimelineView(frame: CGRect(x: 0, y: 0, width: timeSpacer * 24 + extraWidth, height: 80))
        
        // Sent Spacer
        timelineView.extraWidth = extraWidth
        
        // Example event times (9:00-10:00 and 11:00-12:00)
        timelineView.events = [(start: 9.0, end: 10.0), (start: 11.0, end: 12.0), (start: 18.0, end: 18.2)]
        
        scrollView.contentSize = timelineView.frame.size
        scrollView.addSubview(timelineView)
        
        let indicatorView = UIView()
        indicatorView.frame = CGRect(x: self.view.frame.width / 2, y: 100, width: 2, height: 80)
        indicatorView.backgroundColor = .red
        indicatorView.layer.zPosition = 99
        view.addSubview(indicatorView)
        
        timeLabel.text = "Init Time"
        timeLabel.textColor = .white
        timeLabel.frame = CGRect(x: self.view.frame.width / 2, y: 200, width: 400, height: 100)
        view.addSubview(timeLabel)
        
        let buttonTestOffset = UIButton()
        buttonTestOffset.setTitle("Offset", for: .normal)
        buttonTestOffset.addTarget(self, action: #selector(infoButtonPressed(_:)), for: .touchUpInside)
        buttonTestOffset.frame = CGRect(x: self.view.frame.width / 2, y: 400, width: 200, height: 200)
        view.addSubview(buttonTestOffset)
        
        self.view.addSubview(scrollView)
        view.backgroundColor = .gray
    }
    
    func timeString(from hours: Double) -> String {
        // Extract the hour and minute components
        let hour = Int(hours)
        let minute = Int((hours - Double(hour)) * 60)
        
        return "\(hour):\(minute)"
    }
    
    func scrollToOffset(offset: Double) {
        scrollView.contentOffset.x = offset
    }
    
    @objc
    private func infoButtonPressed(_ sender: UIButton) {
        scrollToOffset(offset: 1500)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let timeOffset = scrollView.contentOffset.x / timeSpacer
        let timeString = timeString(from: timeOffset)
        timeLabel.text = "Offset: \(timeString)"
    }
}

final class TimelineView: UIView {
    var events: [(start: CGFloat, end: CGFloat)] = []
    var extraWidth: CGFloat = 0.0
    
    private let totalHours: CGFloat = 24.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        
        let width = rect.width - extraWidth
        let height = rect.height
        let hourWidth = width / totalHours
        
        // Background color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Draw event areas with gradient
        for event in events {
            let startX = event.start / totalHours * width + extraWidth / 2
            let endX = event.end / totalHours * width + extraWidth / 2
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
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1)
        for hour in stride(from: 0, to: totalHours + 1, by: 1) {
            let x = CGFloat(hour) / totalHours * width + extraWidth / 2
            context.move(to: CGPoint(x: x, y: height * 0.4167))
            context.addLine(to: CGPoint(x: x, y: 0))
            context.strokePath()
            
            // Draw shorter markers for each hour, dividing into 6 parts
            let increment = hourWidth / 6.0
            for i in 1..<6 {
                if hour == 24 { break }
                
                let subX = x + CGFloat(i) * increment
                context.move(to: CGPoint(x: subX, y: height * 0.1))
                context.addLine(to: CGPoint(x: subX, y: 0))
                context.strokePath()
            }
            
            let hourString = String(format: "%02d:00", Int(hour))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12.0),
                .foregroundColor: UIColor.black
            ]
            let size = hourString.size(withAttributes: attributes)
            hourString.draw(at: CGPoint(x: x - size.width / 2, y: height - size.height - (height * 0.05)), withAttributes: attributes)
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
}
