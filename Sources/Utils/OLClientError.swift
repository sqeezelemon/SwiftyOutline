// SwiftyOutline
// ↳ OLClientError.swift
//
// Created by @sqeezelemon

import Foundation

public enum OLClientError: Error {
  case invalidResponse
}

extension OLClientError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .invalidResponse:
      return "URLResponse is not HTTPURLResponse"
    }
  }
}
