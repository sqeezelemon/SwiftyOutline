// SwiftyOutline
// ↳ OLServer.swift
//
// Created by @sqeezelemon

import Foundation

public struct OLServer {
  internal init(name: String, serverId: String, metricsEnabled: Bool, createdTimestampMs: Date, portForNewAccessKeys: Int, hostnameForAccessKeys: URL, version: String, accessKeyDataLimit: Int) {
    self.name = name
    self.serverId = serverId
    self.metricsEnabled = metricsEnabled
    self.createdTimestampMs = createdTimestampMs
    self.portForNewAccessKeys = portForNewAccessKeys
    self.hostnameForAccessKeys = hostnameForAccessKeys
    self.version = version
    self.accessKeyDataLimit = accessKeyDataLimit
  }
  
  public var name: String
  public var serverId: String
  public var metricsEnabled: Bool
  public var createdTimestampMs: Date
  public var portForNewAccessKeys: Int
  public var hostnameForAccessKeys: URL
  public var version: String
  public var accessKeyDataLimit: Int?
}

extension OLServer: Decodable {
  enum CodingKeys: CodingKey {
    case name
    case serverId
    case metricsEnabled
    case createdTimestampMs
    case portForNewAccessKeys
    case hostnameForAccessKeys
    case version
    case accessKeyDataLimit
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.serverId = try container.decode(String.self, forKey: .serverId)
    self.metricsEnabled = try container.decode(Bool.self, forKey: .metricsEnabled)
    self.createdTimestampMs = try container.decode(Date.self, forKey: .createdTimestampMs)
    self.portForNewAccessKeys = try container.decode(Int.self, forKey: .portForNewAccessKeys)
    self.hostnameForAccessKeys = try container.decode(URL.self, forKey: .hostnameForAccessKeys)
    self.version = try container.decode(String.self, forKey: .version)
    self.accessKeyDataLimit = try container.decodeIfPresent(OLBytes.self, forKey: .accessKeyDataLimit)?.bytes
  }
}
