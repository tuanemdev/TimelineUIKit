//
//  ViewController.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 14/5/24.
//

import UIKit

class ViewController: UIViewController {
    
    private var testMode: OHTimelineMode = .explore
    private var testEvents: [OHTimelineEvent] = [
        .init(startUnixTimestamp: 1500, endUnixTimestamp: 1590),
        .init(startUnixTimestamp: 1800, endUnixTimestamp: 2000),
    ]
    var seekbarView: OHTimeSeekBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray.withAlphaComponent(0.5)
        
        seekbarView = OHTimeSeekBarView()
        seekbarView.setupEvents(testEvents)
        seekbarView.delegate = self
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
        seekbarView.scrollToTimestamp(1716013284)
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

extension ViewController: OHTimeSeekBarViewDelegate {
    func timeSeekBarView(_ timeSeekBarView: OHTimeSeekBarView, endAt unixTimestamp: Int) {
        print("Stop at: \(unixTimestamp)")
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
