//
//  JotSpot_macApp.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI

@main
struct JotSpot_macApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: JotSpot_macDocument()) { file in
            ContentView(document: file.$document)
            .frame(minWidth: 500, minHeight: 500)
        }
    }
}
