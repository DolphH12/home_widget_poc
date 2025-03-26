//
//  BackgroundIntent.swift
//  Runner
//
//  Created by Dolph Hincapie on 13/03/25.
//

import Foundation
import AppIntents
import UIKit

@available(iOS 17, *)
public struct BackgroundIntent: AppIntent {
  static public var title: LocalizedStringResource = "Copiar al Portapapeles"

  @Parameter(title: "Message")
  var message: String

  public init() {
    message = "******"
  }
  
  public init(message: String) {
    self.message = message
  }

  public func perform() async throws -> some IntentResult {
      UIPasteboard.general.string = message
      return .result()
  }
}
