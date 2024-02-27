// SwiftyOutline
// ↳ OLServerClient.swift
//
// Created by @sqeezelemon

import Foundation
@_implementationOnly import CryptoKit

/// Client for communication with an Outline server.
public final class OLServerClient: NSObject {
  
  
  //MARK: Properties
  
  /// Credentials to be used by the client
  public var credentials: OLCredentials
  
  /// Whether the client should check that SSL certificate's SHA-256 equals `credentials.certSha256`
  public var verifySSL: Bool = true
  
  /// URL Session configured to check the SSL certificate
  private lazy var urlSession: URLSession = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return URLSession(configuration: .default, delegate: self, delegateQueue: queue)
  }()
  
  
  // MARK: Initializers
  
  public init(with credentials: OLCredentials) {
    self.credentials = credentials
  }
  

  // MARK: Networking
  
  /// Creates a request to the server
  ///
  /// - Parameters:
  ///   - path: Path to request, excluding the path component in API URL
  ///   - method: HTTP method for the request
  ///   - data: Request data
  private func request(_ path: String, method: String, data: Data? = nil) -> URLRequest {
    let url: URL
    if #available(iOS 16, macOS 13, *) {
      url = credentials.apiUrl.appending(path: path)
    } else {
      url = credentials.apiUrl.appendingPathComponent(path)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    if let data {
      request.httpBody = data
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    return request
  }
  
  /// Performs a request with the API
  ///
  /// - Parameter request: Request to perform
  @discardableResult private func perform(_ request: URLRequest) async throws -> Data {
    let (data, response) = try await urlSession.data(for: request)
    print(String(data: data, encoding: .utf8)!)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw OLClientError.invalidResponse
    }
    guard httpResponse.statusCode == request.expectedCode else {
      throw try data.decoded(as: OLServerError.self)
    }
    return data
  }
  
  // MARK: Server
  
  /// Returns information about the server
  public func getServer() async throws -> OLServer {
    let request = request("/server", method: "GET")
    return try await perform(request).decoded(as: OLServer.self)
  }
  
  /// Changes the hostname for access keys.
  ///
  /// - Parameter hostname: A valid hostname or IP address. If it's a hostname, DNS must be set up independently of this API.
  public func setHostname(to hostname: URL) async throws {
    let request = request("/server/hostname-for-access-keys", method: "PUT",
                          data: try ["hostname" : hostname].encoded())
    try await perform(request)
  }
  
  /// Renames the server.
  ///
  /// - Parameter name: New server name (<= 100 characters)
  public func renameServer(to name: String) async throws {
    let request = request("/name", method: "PUT",
                          data: try ["name" : name].encoded())
    try await perform(request)
  }
  
  /// Returns whether metrics is being shared.
  public func metricsAreEnabled() async throws -> Bool {
    let request = request("/metrics/enabled", method: "GET")
    struct Response: Decodable { let metricsEnabled: Bool }
    return try await perform(request).decoded(as: Response.self).metricsEnabled
  }
  
  /// Enables or disables sharing of metrics.
  ///
  /// - Parameter enabled: Whether metrics sharing should be enabled
  public func setMetricsSharing(to enabled: Bool) async throws {
    let request = request("/metrics/enabled", method: "PUT",
                          data: try ["metricsEnabled" : enabled].encoded())
    try await perform(request)
  }
  
  
  // MARK: Access Keys
  
  /// Changes the default port for newly created access keys. This can be a port already used for access keys.
  public func setDefaultPort(to port: Int) async throws {
    let request = request("/server/port-for-new-access-keys", method: "POST",
                          data: try ["port" : port].encoded())
    try await perform(request)
  }
  
  /// Creates an acces key with the provided encryption method.
  ///
  /// - Warning: Everything other than `method` is fairly new and may by ignored by older server versions. For backwards compatability, it is best to resort to previously available APIs for renaming and data limits.
  ///
  /// - Parameters:
  ///   - name: Name of the newly created key
  ///   - method: Encryption method to be used for the key. For all allowed encryption methods, see [client code](https://github.com/Jigsaw-Code/outline-server/tree/master/src/shadowbox/server/server_access_key.ts#L102)
  ///   - password: Password to be used by the key
  ///   - port: Port to be used by the client
  ///   - limit: Non-negative data transfer limit in bytes
  public func createAccessKey(
    name: String? = nil,
    method: String? = nil,
    password: String? = nil,
    port: Int? = nil,
    limit: Int? = nil
  ) async throws -> OLAccessKey {
    struct Request: Encodable {
      let name: String?
      let method: String?
      let password: String?
      let port: Int?
      let dataLimit: OLBytes?
    }
    let data = Request(name: name, method: method, password: password, port: port,
                       dataLimit: (limit != nil) ? OLBytes(bytes: limit!) : nil)
    let request = request("/access-keys", method: "POST", data: try data.encoded())
    return try await perform(request).decoded(as: OLAccessKey.self)
  }
  
  /// Returns all active access keys.
  public func getAccessKeys() async throws -> [OLAccessKey] {
    let request = request("/access-keys", method: "GET")
    struct Response: Decodable { let accessKeys: [OLAccessKey] }
    return try await perform(request).decoded(as: Response.self).accessKeys
  }
  
  /// Deletes an access key
  ///
  /// - Parameter id: ID of the key to delete
  public func deleteAccessKey(_ id: String) async throws {
    let request = request("/access-keys/\(id)", method: "DELETE")
    try await perform(request)
  }
  
  /// Renames an access key
  ///
  /// - Parameters:
  ///   - id: ID of the key
  ///   - name: New acces key name
  public func renameAccessKey(_ id: String, to name: String) async throws {
    let request = request("/access-keys/\(id)/name", method: "PUT", data: try ["name" : name].encoded())
    try await perform(request)
  }
  
  /// Returns bytes transferred per access key.
  ///
  /// - Returns: Dictionary of format `[Key : Bytes transferred]`
  public func getDataTransfersPerKey() async throws -> [String : Int] {
    let request = request("/metrics/transfer", method: "GET")
    struct Response: Decodable { let bytesTransferredByUserId: [String : Int] }
    return try await perform(request).decoded(as: Response.self).bytesTransferredByUserId
  }
  
  
  // MARK: Data limits
  
  /// Sets a data transfer limit for all access keys
  ///
  /// - Parameter limit: Non-negative amount of bytes
  public func setDataTransferLimit(_ limit: Int) async throws {
    let request = request("/server/access-key-data-limit", method: "PUT",
                          data: try ["limit" : OLBytes(bytes: limit)].encoded())
    try await perform(request)
  }
  
  /// Removes the access key data limit, lifting data transfer restrictions on all access keys.
  public func removeDataTransferLimit() async throws {
    let request = request("/server/access-key-data-limit", method: "DELETE")
    try await perform(request)
  }
  
  /// Sets a custom transfer limit for a key.
  ///
  /// - Parameters:
  ///   - id: ID of the key
  ///   - limit: Non-negative amount of bytes
  public func setDataTransferLimit(for id: String, to limit: Int) async throws {
    let request = request("/access-keys/\(id)/data-limit", method: "PUT",
                          data: try ["limit" : OLBytes(bytes: limit)].encoded())
    try await perform(request)
  }
  
  /// Removes the custom data transfer limit for a key.
  ///
  /// - Parameter id: ID of the key
  public func removeDataTransferLimit(for id: String) async throws {
    let request = request("/access-keys/\(id)/data-limit", method: "DELETE")
    try await perform(request)
  }
}

//MARK: SSL Verification

extension OLServerClient: URLSessionDelegate {
  public func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
      guard let serverTrust = challenge.protectionSpace.serverTrust else {
        completionHandler(.cancelAuthenticationChallenge, nil)
        return
      }
      let policy = SecPolicyCreateSSL(true, nil)
      SecTrustSetPolicies(serverTrust, policy)
      
      guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
      let certificate = certificates.first else {
        completionHandler(.cancelAuthenticationChallenge, nil)
        return
      }
      
      let data = SecCertificateCopyData(certificate) as Data
      let hash = SHA256.hash(data: data)
      guard hash == credentials.certSha256 else {
        completionHandler(.cancelAuthenticationChallenge, nil)
        return
      }
      
      completionHandler(.useCredential, URLCredential(trust: serverTrust))
  }
}


//MARK: Codable

fileprivate extension Data {
  func decoded<T: Decodable>(as: T.Type) throws -> T {
    return try JSONDecoder().decode(T.self, from: self)
  }
}

fileprivate extension Encodable {
  func encoded() throws -> Data {
    return try JSONEncoder().encode(self)
  }
}


//MARK: Utils

fileprivate extension URLRequest {
  var expectedCode: Int {
    switch self.httpMethod {
    case "GET":
      return 200
    case "POST":
      return 201
    case "PUT", "DELETE":
      return 204
    default:
      return 200
    }
  }
}
