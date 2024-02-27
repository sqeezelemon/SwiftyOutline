// SwiftyOutline
// ↳ OLCredentials.swift
//
// Created by @sqeezelemon

import Foundation

/// Credentials for an Outline server.
public struct OLCredentials {
  /// Outline server API URL
  public var apiUrl: URL
  
  /// SHA-256 Fingerprint of the server's SSL certificate.
  public var certSha256: Data
  
  /// Initializes the credentials
  ///
  /// - Parameters:
  ///   - apiUrl: Management API URL
  ///   - certSha256: SHA256 hash of the server SSL certificate
  public init(apiUrl: URL, certSha256: Data) {
    self.apiUrl = apiUrl
    self.certSha256 = certSha256
  }
  
  /// Initializes the credentials
  ///
  /// - Parameters:
  ///  - apiUrl: Management API URL
  ///  - certSha256: Base 16 encoded SHA256 hash of the server SSL certificate
  public init?(apiUrl: URL, certSha256: String) throws {
    guard let certData = certSha256.hexData() else { return nil }
    self.init(apiUrl: apiUrl, certSha256: certData)
  }
}


extension OLCredentials: Decodable {
  private enum CodingKeys: CodingKey {
    case apiUrl
    case certSha256
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.apiUrl = try container.decode(URL.self, forKey: .apiUrl)
    guard let certData = try container.decode(String.self, forKey: .certSha256).hexData() else {
      throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.certSha256], debugDescription: "Invalid certificate SHA256"))
    }
    self.certSha256 = certData
  }
}


//MARK: Utils

fileprivate extension String {
  func hexData() -> Data? {
    guard self.count == 64 else { return nil }
    var data = Data(capacity: count / 2)
    var indexIsEven = false
    for i in self.indices {
      indexIsEven.toggle()
      guard indexIsEven else { continue }
      guard let byte = UInt8(self[i...index(after: i)], radix: 16) else { return nil }
      data.append(byte)
    }
    return data
  }
}
