//
//  ContentView.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI
import AppKit
import StoreKit

struct ContentView: View {
	@Environment(\.undoManager) var undoManager
	@Environment(\.requestReview) private var requestReview
	@Binding var document: JotSpot_macDocument
	@State private var title: String = ""
	
	var body: some View {
		VStack {
			toolbar
			
			// Document title bar
			HStack {
				TextField("New Document", text: $title)
				Button("Name Document", action: { print(title) })
			}
			.padding(.horizontal)
			
			// Rich text editor
			RichTextEditor(
				attributedText: $document.attributedText,
				undoManager: undoManager
			)
			.padding()
			.background(Color(nsColor: .textBackgroundColor))
			.clipShape(RoundedRectangle(cornerRadius: 8))
			.shadow(color: .black.opacity(0.15), radius: 4, y: 2)
			.padding()
		}
		.toolbar {
			navBar
		}
	}
	
	var navBar: some View {
		HStack {
			Button("Colors", systemImage: "paintpalette", action: showColorPanel)
			Button("Fonts", systemImage: "textformat", action: showFontPanel)
			Button("Rate", systemImage: "star", action: { requestReview() })
			Button("Help", systemImage: "questionmark.circle", action: { print("help") })
		}
	}
	
	var toolbar: some View {
		HStack {
			Button(action: { undoManager?.undo() }) {
				Image(systemName: "arrow.uturn.backward")
			}
			.help("Undo")
			
			Button(action: saveAction) {
				Image(systemName: "square.and.arrow.down")
			}
			.help("Save")
			
			Button(action: openAction) {
				Image(systemName: "archivebox")
			}
			.help("Open")
			
			Button(action: copyAction) {
				Image(systemName: "document.on.document")
			}
			.help("Copy")
			
			Button(action: pasteAction) {
				Image(systemName: "document.on.clipboard")
			}
			.help("Paste")
			
			Button(action: cutAction) {
				Image(systemName: "scissors")
			}
			.help("Cut")

			Button(action: printAction) {
				Image(systemName: "printer")
			}
			.help("Print")
			
			Button(action: selectAllAction) {
				Image(systemName: "character.textbox")
			}
			.help("Select All")
		}
		.padding(.vertical, 8)
	}
	
	// MARK: - Formatting Actions
	
	private func showColorPanel() {
		NSColorPanel.shared.orderFront(nil)
		NSApp.sendAction(#selector(NSTextView.changeColor(_:)), to: nil, from: nil)
	}
	
	private func showFontPanel() {
		NSFontPanel.shared.orderFront(nil)
		NSFontManager.shared.orderFrontFontPanel(nil)
	}
	
	// MARK: - File Actions
	
	private func saveAction() {
		NSApplication.shared.sendAction(#selector(NSDocument.save(_:)), to: nil, from: nil)
	}
	
	private func openAction() {
		NSApplication.shared.sendAction(#selector(NSDocumentController.openDocument(_:)), to: nil, from: nil)
	}
	
	private func copyAction() {
		NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
	}
	
	private func pasteAction() {
		NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
	}
	
	private func cutAction() {
		NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
	}
	
	private func selectAllAction() {
		NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
	}
	
	private func printAction() {
		let printInfo = NSPrintInfo.shared
		printInfo.topMargin = 50.0
		printInfo.bottomMargin = 50.0
		printInfo.leftMargin = 50.0
		printInfo.rightMargin = 50.0
		
		let textView = NSTextView()
		textView.textStorage?.setAttributedString(document.attributedText)
		
		// Set up the text container for proper printing
		let pageWidth = printInfo.paperSize.width - printInfo.leftMargin - printInfo.rightMargin
		textView.frame = NSRect(x: 0, y: 0, width: pageWidth, height: 10000)
		textView.sizeToFit()
		
		let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
		printOperation.printPanel.options.insert([.showsPageSetupAccessory, .showsPreview])
		printOperation.run()
	}
}

// MARK: - Rich Text Editor

struct RichTextEditor: NSViewRepresentable {
	@Binding var attributedText: NSAttributedString
	var undoManager: UndoManager?
	
	func makeNSView(context: Context) -> NSScrollView {
		let scrollView = NSTextView.scrollableTextView()
		
		guard let textView = scrollView.documentView as? NSTextView else {
			return scrollView
		}
		
		// Configure the text view
		textView.delegate = context.coordinator
		textView.isRichText = true
		textView.allowsUndo = true
		textView.usesFontPanel = true
		textView.usesRuler = true
		textView.isRulerVisible = false
		textView.allowsImageEditing = true
		textView.importsGraphics = true
		textView.backgroundColor = .textBackgroundColor
		textView.textColor = .textColor
		
		// Enable various rich text features
		textView.isAutomaticQuoteSubstitutionEnabled = true
		textView.isAutomaticDashSubstitutionEnabled = true
		textView.isAutomaticSpellingCorrectionEnabled = false
		textView.isAutomaticTextReplacementEnabled = true
		textView.isAutomaticLinkDetectionEnabled = true
		
		// Set default font
		textView.font = NSFont.systemFont(ofSize: 14)
		
		// Set up typing attributes
		textView.typingAttributes = [
			.font: NSFont.systemFont(ofSize: 14),
			.foregroundColor: NSColor.textColor
		]
		
		// Configure text container for proper wrapping
		textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: .greatestFiniteMagnitude)
		textView.textContainer?.widthTracksTextView = true
		textView.isHorizontallyResizable = false
		textView.isVerticallyResizable = true
		textView.autoresizingMask = [.width]
		
		// Set initial content
		if attributedText.length > 0 {
			textView.textStorage?.setAttributedString(attributedText)
		}
		
		// Configure scroll view
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = false
		scrollView.autohidesScrollers = true
		scrollView.borderType = .noBorder
		
		return scrollView
	}
	
	func updateNSView(_ scrollView: NSScrollView, context: Context) {
		guard let textView = scrollView.documentView as? NSTextView else { return }
		
		// Only update if the content has changed externally
		if !context.coordinator.isEditing {
			let currentText = textView.attributedString()
			if !currentText.isEqual(to: attributedText) {
				let selectedRanges = textView.selectedRanges
				textView.textStorage?.setAttributedString(attributedText)
				textView.selectedRanges = selectedRanges
			}
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, NSTextViewDelegate {
		var parent: RichTextEditor
		var isEditing = false
		
		init(_ parent: RichTextEditor) {
			self.parent = parent
		}
		
		func textDidBeginEditing(_ notification: Notification) {
			isEditing = true
		}
		
		func textDidEndEditing(_ notification: Notification) {
			isEditing = false
		}
		
		func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView else { return }
			parent.attributedText = textView.attributedString()
		}
		
		// Support for drag and drop of images and files
		func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
			return true
		}
	}
}

#Preview {
	ContentView(document: .constant(JotSpot_macDocument()))
}
