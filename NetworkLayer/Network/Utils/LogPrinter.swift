//
//  NetworkLogger.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 13/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

// swiftlint:disable no_print_statements_rule
public struct LogPrinter {
  public static func debug(_ message: String) {
#if DEBUG
    print("🌐 \(message)")
#endif
  }
}
