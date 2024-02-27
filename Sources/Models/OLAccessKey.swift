// SwiftyOutline
// ↳ OLAccessKey.swift
//
// Created by @sqeezelemon

import Foundation

public struct OLAccessKey {
  public init(id: String, name: String, password: String, port: Int, method: String, accessUrl: URL, dataLimit: Int? = nil) {
    self.id = id
    self.name = name
    self.password = password
    self.port = port
    self.method = method
    self.accessUrl = accessUrl
    self.dataLimit = dataLimit
  }
  
  public var id: String
  public var name: String
  public var password: String
  public var port: Int
  public var method: String
  public var accessUrl: URL
  public var dataLimit: Int?
}

extension OLAccessKey: Decodable {
  enum CodingKeys: CodingKey {
    case id
    case name
    case password
    case port
    case method
    case accessUrl
    case dataLimit
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.password = try container.decode(String.self, forKey: .password)
    self.port = try container.decode(Int.self, forKey: .port)
    self.method = try container.decode(String.self, forKey: .method)
    self.accessUrl = try container.decode(URL.self, forKey: .accessUrl)
    self.dataLimit = try container.decodeIfPresent(OLBytes.self, forKey: .dataLimit)?.bytes
  }
}
