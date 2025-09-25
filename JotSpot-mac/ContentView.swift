//
//  ContentView.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @Binding var document: JotSpot_macDocument
	@State private var title: String = ""

    var body: some View {
		VStack {
			toolbar
			
			HStack {
				TextField("New Document", text: $title)
				Button("Name Document", action: {print(title)})
			}
			
			Divider()
			
			TextEditor(text: $document.text)
				.padding()
				.scrollClipDisabled()
				.clipShape(RoundedRectangle(cornerRadius: 13))
				.shadow(color: .black.opacity(0.2), radius: 5)
		}
		.padding()
		.toolbar {
			navBar
		}
    }
	
	var navBar: some View {
		HStack {
			Button("Colors", systemImage: "paintpalette", action: {print("colors")})
			Button("Fonts", systemImage: "textformat", action: {print("Fonts")})
			Button("Rate", systemImage: "star", action: {print("rate")})
			Button("Help", systemImage: "questionmark.circle", action: {print("help")})
		}
	}
	
	var toolbar: some View {
		HStack {
			Button(action: {}) {
				Image(systemName: "arrow.uturn.backward")
			}
			
			Button(action: saveAction) {
				Image(systemName: "square.and.arrow.down")
			}
			
			Button(action: openAction) {
				Image(systemName: "archivebox")
			}
			
			Button(action: copyAction) {
				Image(systemName: "document.on.document")
			}
			.disabled(document.text.isEmpty)
			
			Button(action: pasteAction) {
				Image(systemName: "document.on.clipboard")
			}
			
			Button(action: cutAction) {
				Image(systemName: "scissors")
			}
			.disabled(document.text.isEmpty)
			
			Button(action: printAction) {
				Image(systemName: "printer")
			}
			.disabled(document.text.isEmpty)
		}
	}
	
	// MARK: - Button Actions
	
	private func saveAction() {
		// In a document-based app, we can trigger a save
		// The system will handle the actual save process
		NSApplication.shared.sendAction(#selector(NSDocument.save(_:)), to: nil, from: nil)
	}
	
	private func openAction() {
		// Trigger the system's open dialog
		NSApplication.shared.sendAction(#selector(NSDocumentController.openDocument(_:)), to: nil, from: nil)
	}
	
	private func copyAction() {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(document.text, forType: .string)
	}
	
	private func pasteAction() {
		let pasteboard = NSPasteboard.general
		if let string = pasteboard.string(forType: .string) {
			document.text += string
		}
	}
	
	private func cutAction() {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(document.text, forType: .string)
		document.text = ""
	}
	
	private func printAction() {
		let printInfo = NSPrintInfo.shared
		printInfo.topMargin = 50.0
		printInfo.bottomMargin = 50.0
		printInfo.leftMargin = 50.0
		printInfo.rightMargin = 50.0
		
		let textView = NSTextView()
		textView.string = document.text
		textView.font = NSFont.systemFont(ofSize: 12)
		
		let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
		printOperation.printPanel.options.insert([.showsPageSetupAccessory, .showsPreview])
		printOperation.run()
	}
}

#Preview {
    ContentView(document: .constant(JotSpot_macDocument()))
}
