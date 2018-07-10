//
//  RemotePeersViewController.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 09.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit

class RemotePeersViewController: UIViewController {
  
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
  
  @IBOutlet private weak var logView: LogView!
  @IBOutlet private weak var tableView: UITableView!
  var model: RemotePeersModel!
  
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
    
    model.startSearch()
    title = "Remote peers"
  }
  
 
  private func populateUi(with state: State) {
    switch state {
      
    case .didReceiveDeviceInfo(let deviceInfo):
      var devices = self.devices
      if let index = devices.index(where: {$0.device.cid == deviceInfo.device.cid}) {
        devices.remove(at: index)
        devices.insert(deviceInfo, at: index)
        self.devices = devices
      }
      
    case .didFoundDevices(let devices):
      self.devices = devices
      
    case .didFinishTransfer(let device):
      var devices = self.devices
      if let index = devices.index(where: {$0.device.cid == device.device.cid}) {
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
    let searchButton = UIBarButtonItem(title: "Add peer", style: .plain, target: self, action: #selector(searchAction(sender:)))
    navigationItem.rightBarButtonItem = searchButton
  }
  
  
  @objc private func searchAction(sender: UIBarButtonItem) {
    addNewDevice()
//    model.startSearch()
  }
  
  @IBAction func schemeChanged(_ sender: Any) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }
    model.scheme = segmentedControl.selectedSegmentIndex == 0 ? .coaps : .coap
  }
  
  private func addNewDevice() {
    let controller = UIAlertController(title: "Add device CID", message: nil, preferredStyle: .alert)
    controller.addTextField { textField in
      textField.placeholder = "Device CID"
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak controller] _ in
      controller?.dismiss(animated: true, completion: nil)
    }
    let create = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] _ in
      if let cid = controller?.textFields?.first?.text {
        self?.model.addPeer(cid: cid)
      }
    }
    controller.addAction(cancel)
    controller.addAction(create)
    present(controller, animated: true, completion: nil)
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
  
  @IBAction func getInfoAction(_ sender: Any) {
  }
}

extension RemotePeersViewController: UITableViewDelegate, UITableViewDataSource {
  
  
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
