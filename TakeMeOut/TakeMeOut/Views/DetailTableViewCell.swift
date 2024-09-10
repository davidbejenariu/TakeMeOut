//
//  DetailTableViewCell.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 06.06.2023.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    let detailLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let infoLabel: UITextView = {
        let label = UITextView()
        
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        label.backgroundColor = .secondarySystemBackground
        label.isEditable = false
        label.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.dataDetectorTypes = .all
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(detailLabel)
        contentView.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 2),
            infoLabel.leadingAnchor.constraint(equalTo: detailLabel.leadingAnchor, constant: -5),
            infoLabel.trailingAnchor.constraint(equalTo: detailLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            contentView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
