//
//  ProxyViewController.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 06.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit

class ProxyViewController: UIViewController {
  
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
  private var proxyAddressString: String?
  private var searchButton: UIBarButtonItem!

  @IBOutlet private weak var proxyTextField: UITextField!
  @IBOutlet private weak var logView: LogView!
  @IBOutlet private weak var tableView: UITableView!
  var model: ProxyModel!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    showSearchButton()

    model.coalaAgent.didReceiveLog = { [weak self] log in
      self?.logView.add(log: log)
    }

    model.viewNotificationBlock = { [weak self] state in
      self?.populateUi(with: state)
    }

    title = "Proxy request"
    proxyTextField.delegate = self
    showAlert()
  }
  
  private func showAlert() {
    let alertController = UIAlertController(title: "Attention!", message: "Be sure that you start CoalaProxyGo application on computer of your local network", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
      alertController?.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(ok)
    present(alertController, animated: true, completion: nil)
  }
  
  private func populateUi(with state: State) {
    switch state {
    case .didReceiveDeviceInfo(let deviceInfo):
      var devices = self.devices
      if let index = devices.index(where: {$0.device.address == deviceInfo.device.address}) {
        devices.remove(at: index)
        devices.insert(deviceInfo, at: index)
        self.devices = devices
        
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
  
  
  @objc private func searchAction(sender: UIBarButtonItem) {
    showSearchSpinner()
    model.startSearch()
  }
  
  @IBAction func schemeChanged(_ sender: Any) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }
    model.scheme = segmentedControl.selectedSegmentIndex == 0 ? .coaps : .coap
  }
  
  private func showRequestTypes(device: ArqDeviceViewModel) {
    let alertController = UIAlertController(title: "Choose request", message: nil, preferredStyle: .actionSheet)
    let infoRequest = UIAlertAction(title: "/info request", style: .default) { [weak self] _ in
      self?.model.getInfo(for: device, proxyString: self?.proxyAddressString)
    }
    
    let block1Request = UIAlertAction(title: "Send 25KBytes", style: .default) { [weak self] _ in
      self?.model.startArq(with: device, type: .upload, proxyString: self?.proxyAddressString)
    }
    
    let block2Request = UIAlertAction(title: "Receive 25KBytes", style: .default) { [weak self] _ in
      self?.model.startArq(with: device, type: .download, proxyString: self?.proxyAddressString)
    }
    
    let multiblockRequest = UIAlertAction(title: "Send and receive 25KBytes", style: .default) { [weak self] _ in
      self?.model.startArq(with: device, type: .upload, proxyString: self?.proxyAddressString)
      self?.model.startArq(with: device, type: .download, proxyString: self?.proxyAddressString)
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak alertController] _ in
      alertController?.dismiss(animated: true, completion: nil)
    }
    
    alertController.addAction(infoRequest)
    alertController.addAction(block1Request)
    alertController.addAction(block2Request)
    alertController.addAction(multiblockRequest)
    alertController.addAction(cancel)
    present(alertController, animated: true, completion: nil)
  }
  
  
}


extension ProxyViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    proxyAddressString = textField.text
    textField.resignFirstResponder()
    return true
  }
}


extension ProxyViewController: UITableViewDelegate, UITableViewDataSource {
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return devices.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProxyCell") as! ProxyCell
    let viewModel = devices[indexPath.row]
    cell.configure(with: viewModel)
    return cell
  }
  
  

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let device = devices[indexPath.row]
    showRequestTypes(device: device)
    tableView.deselectRow(at: indexPath, animated: true)
  }

}
