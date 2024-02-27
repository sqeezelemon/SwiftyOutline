# SwiftyOutline

Client for Outline VPN management API with SSL-pinning, built using async/await and Codable.

> [!IMPORTANT]
> On iOS, App Transport Security should be disabled, otherwise SSL verification will always fail.

### Requirements

| iOS | MacOS |
| --- | ----- |
| 15  | 12    |

### Installation

SwiftyOutline is available for install via SPM. Simply add this to your dependencies inside your Package.swift file:
```swift
.package(url: "https://github.com/sqeezelemon/SwiftyOutline.git", from: "1.0.0")
```

### Usage
```swift
import SwiftyOutline                           // Import

let credentials = OLCredentials(...)           // Initialize credentials
let client = OLServerClient(with: credentials) // Initialize client
client.getAccessKeys()                         // Enjoy :)
```

***
[Official Outline API docs](https://github.com/Jigsaw-Code/outline-server/tree/master/src/shadowbox)
