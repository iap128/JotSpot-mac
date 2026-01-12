//
//  JotSpot_macApp.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI
import AppKit

private var releaseNotesWindowController: NSWindowController?


@main
struct JotSpot_macApp: App {
	@Environment(\.openWindow) private var openWindow
	
    var body: some Scene {
        DocumentGroup(newDocument: JotSpot_macDocument()) { file in
            ContentView(document: file.$document)
            .frame(minWidth: 500, minHeight: 500)
        }
		.defaultSize(width: 500, height: 500)
        .commands {
			TextFormattingCommands()
			TextEditingCommands()
			
            CommandGroup(after: .help) {
				Button("Release Notes") {
					openWindow(id: "release-notes")
				}
				
                Button("Support") {
                    if let url = URL(string: "https://n818pe.com/contact") {
                        NSWorkspace.shared.open(url)
                    }
                }

                Button("JotSpot Website") {
                    if let url = URL(string: "https://n818pe.com/jotspot-mac") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
		
		
		Window("Release Notes", id: "release-notes") {
			ReleaseNotes()
				.windowResizeBehavior(.disabled)
		}
		.defaultSize(width: 400, height: 300)
    }
}
