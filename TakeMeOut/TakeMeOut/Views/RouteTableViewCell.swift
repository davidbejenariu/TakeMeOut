//
//  RouteTableViewCell.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 24.05.2023.
//

import UIKit

class RouteTableViewCell: UITableViewCell {
    let routeData: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 24, weight: .bold)
        timeLabel.textColor = .label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        
        let distanceLabel = UILabel()
        distanceLabel.font = .systemFont(ofSize: 16)
        distanceLabel.textColor = .secondaryLabel
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: view.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 1),
            distanceLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor)
        ])
        
        return view
    }()
    
    let goButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("GO", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(routeData)
        contentView.addSubview(goButton)
        
        NSLayoutConstraint.activate([
            routeData.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            routeData.heightAnchor.constraint(equalToConstant: 50),
            routeData.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            routeData.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            goButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            goButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            goButton.widthAnchor.constraint(equalToConstant: 60),
            goButton.heightAnchor.constraint(equalTo: goButton.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}
