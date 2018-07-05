//
//  ArqViewController.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 03.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit
import Coala

class ArqViewController: UIViewController {
  
  enum State {
    case didReceiveDeviceInfo(ArqDeviceViewModel)
    case didFoundDevices([ArqDeviceViewModel])
    case didFinishTransfer(ArqDeviceViewModel)
  }
  
  private var devices = [ArqDeviceViewModel]() {
    didSet {
      showSearchButton()
      tableView.beginUpdates()
      tableView.reloadSections([0], with: .automatic)
      tableView.endUpdates()
    }
  }
  
  private var searchButton: UIBarButtonItem!
  
  @IBOutlet private weak var setupSizeButton: UIButton!
  @IBOutlet private weak var sizeLabel: UILabel!
  @IBOutlet private weak var sizePickerView: UIView!
  @IBOutlet private weak var sizeSlider: UISlider!
  @IBOutlet private weak var logView: LogView!
  @IBOutlet private weak var tableView: UITableView!
  var model: ArqModel!
  private var size: Int = 5
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    sizePickerView.isHidden = model.arqType == .upload
    setupSizeButton.isHidden = model.arqType == .upload
    showSearchButton()
    model.coalaAgent.didReceiveLog = { [weak self] log in
      self?.logView.add(log: log)
    }
    model.viewNotificationBlock = { [weak self] state in
      self?.populateUi(with: state)
    }
    title = model.arqType == .upload ? "ARQ Upload" : "ARQ Download"
    
  }
  
  private func populateUi(with state: State) {
    switch state {
    case .didReceiveDeviceInfo(let deviceInfo):
      var devices = self.devices
      if let index = devices.index(where: {$0.device.address == deviceInfo.device.address}) {
        devices.remove(at: index)
        devices.insert(deviceInfo, at: index)
        self.devices = devices
        if model.arqType == .upload {
          sizePickerView.isHidden = false
        }
      }
    case .didFoundDevices(let devices):
      self.devices = devices
      
    case .didFinishTransfer(let device):
      var devices = self.devices
      if let index = devices.index(where: {$0.device.address == device.device.address}) {
        devices.remove(at: index)
        devices.insert(device, at: index)
        self.devices = devices
      }
    }
  }
  
  private func setupTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150.0
    tableView.dataSource = self
    tableView.delegate = self
    tableView.setContentInsetAdjustment(enabled: false, in: self)
  }
  
  private func showSearchSpinner() {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.hidesWhenStopped = true
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    spinner.startAnimating()
  }
  
  func showSearchButton() {
    let searchButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchAction(sender:)))
    navigationItem.rightBarButtonItem = searchButton
    
  }
  @IBAction func schemeChanged(_ sender: Any) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }
    model.scheme = segmentedControl.selectedSegmentIndex == 0 ? .coaps : .coap    
  }
  
  @IBAction func setupBlockSize(_ sender: Any) {
    size = Int(sizeSlider.value * 5.0)
    model.setupBlockSize(size: size)
    let alertController = UIAlertController(title: "Success!", message: "Outgoing size for incoming get requests setup", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak alertController] _ in
      alertController?.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(okAction)
    present(alertController, animated: true, completion: nil)
  }
  
  @objc private func searchAction(sender: UIBarButtonItem) {
    showSearchSpinner()
    model.startSearch()
  }
  

  @IBAction func didDragSlider(_ sender: Any) {
    size = Int(sizeSlider.value * 5.0)
    sizeLabel.text = "\(size) KByte"
  }
}

extension ArqViewController: UITableViewDelegate, UITableViewDataSource {
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return devices.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ArqCell") as! ArqCell
    let viewModel = devices[indexPath.row]
    cell.configure(with: viewModel)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let device = devices[indexPath.row]
    model.startArq(with: device.device, size: size)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
