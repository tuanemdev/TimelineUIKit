//
//  OHTimeView.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 18/5/24.
//

import UIKit

final class OHTimeView: UIView {
    private let timeBorderView: UIView = .init()
    private let timeLabel: UILabel = .init()
    
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
