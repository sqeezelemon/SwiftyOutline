// SwiftyOutline
// ↳ OLServerError.swift
//
// Created by @sqeezelemon

import Foundation

public enum OLServerError: Error {
  case error(code: String, message: String)
  case unknown
}

extension OLServerError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .error(let code, let message):
      return "\(code) - \(message)"
    case .unknown:
      return "Unknown error"
    }
  }
}

extension OLServerError: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      self = .error(
        code: try values.decode(String.self, forKey: .code),
        message: try values.decode(String.self, forKey: .message))
    } catch {
      self = .unknown
    }
  }
  
  enum CodingKeys: CodingKey {
    case code, message
  }
}
