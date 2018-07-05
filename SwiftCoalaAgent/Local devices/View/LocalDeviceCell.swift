//
//  LocalDeviceCell.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 30.06.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit

class LocalDeviceCell: UITableViewCell {


  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var cidLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!


  func configure(with viewModel: LocalDeviceViewModel) {
    nameLabel.text = viewModel.peerInfo?.name ?? viewModel.address
    cidLabel.text = viewModel.peerInfo?.cid
    messageLabel.text = viewModel.peerInfo?.message
  }
  
}
