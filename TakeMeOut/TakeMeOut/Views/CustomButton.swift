//
//  CustomButton.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 06.06.2023.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    init(labelText: String, systemImageName: String, buttonColor: UIColor) {
        super.init(frame: .zero)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
        if let img = UIImage(systemName: systemImageName, withConfiguration: symbolConfiguration) {
            image.image = img
            image.tintColor = .white
        }

        label.text = labelText
        self.backgroundColor = buttonColor
        
        setupButton()
    }
        
    
    private func setupButton() {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(contentView)
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        self.layer.cornerRadius = 10

        NSLayoutConstraint.activate([
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
