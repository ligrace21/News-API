//
//  NetworkMonitor.swift
//  News API
//
//  Created by user on 10/31/21.
//

import Network

protocol NetworkMonitorDelegate: AnyObject {
    func statusDidChange(status: NWPath.Status)
}

class NetworkMonitor {
    var delegates: [NetworkMonitorDelegate]? = []
    
  static let shared = NetworkMonitor()
  var isConnected: Bool { status == .satisfied }

  private let monitor = NWPathMonitor()
  private var status = NWPath.Status.requiresConnection

  private init() {
    startMonitoring()
  }

  func startMonitoring() {
    monitor.pathUpdateHandler = { [weak self] path in
      self?.status = path.status
        guard let self = self, let delegates = self.delegates else {
            return
        }
        
        for delegate in delegates {
            delegate.statusDidChange(status: path.status)
        }
    }
    let queue = DispatchQueue(label: "NetworkMonitor")
    monitor.start(queue: queue)
  }

  func stopMonitoring() {
    monitor.cancel()
  }
    
    func addDelegate(delegate: NetworkMonitorDelegate) {
        self.delegates?.append(delegate)
    }
    
    func removeDelegate(delegate: NetworkMonitorDelegate) {
        if let index = delegates?.firstIndex(where: {$0 === delegate}) {
            self.delegates?.remove(at: index)
        }
    }
}
