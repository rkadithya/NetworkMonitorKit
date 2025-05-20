//
//  NetworkMonitor.swift
//  NetworkMonitorKit
//
//  Created by RK Adithya on 19 May 2025
//

import Foundation
import Network
import Combine

@available(iOS 14.0, *)
public final class NetworkMonitor: ObservableObject, @unchecked Sendable {
    
    public static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    @Published public private(set) var isConnected: Bool = true

    private var cancellables = Set<AnyCancellable>()

    private init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "NetworkMonitorQueue")

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            if path.status == .satisfied {
                self.checkRealInternetConnectivity()
            } else {
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }

    private func checkRealInternetConnectivity() {
        guard let url = URL(string: "https://www.google.com/generate_204") else { return }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { [weak self] _, response, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    self.isConnected = true
                } else {
                    self.isConnected = false
                }
            }
        }.resume()
    }
}
