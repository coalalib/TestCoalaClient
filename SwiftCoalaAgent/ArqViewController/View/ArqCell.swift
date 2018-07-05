//
//  ArqCell.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 03.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit


class ArqCell: UITableViewCell {
  
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var cidLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  
  override func awakeFromNib() {
    messageLabel.text = ""
  }
  
  override func prepareForReuse() {
    nameLabel.text = nil
    cidLabel.text = nil
    messageLabel.text = nil
  }
  
  func configure(with viewModel: ArqDeviceViewModel) {
    nameLabel.text = viewModel.device.peerInfo?.name ?? viewModel.device.address
    cidLabel.text = viewModel.device.peerInfo?.cid
    if let speed = viewModel.transferedSpeed, let data = viewModel.dataSize {
      messageLabel.text = "Data of size \(data) Kbytes \nwas transfered with speed \(speed) KBytes/s"
    }
    
  }
  
}
