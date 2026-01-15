//
//  JotSpot_macDocument.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

// Define the custom .jot UTType that conforms to RTF
extension UTType {
    static var jotDocument: UTType {
        UTType(exportedAs: "com.jotspot.jot-document", conformingTo: .rtf)
    }
}

struct JotSpot_macDocument: FileDocument {
    var attributedText: NSAttributedString
    
    init(attributedText: NSAttributedString = NSAttributedString(string: "")) {
        self.attributedText = attributedText
    }
    
    // Support .jot, RTF, RTFD, and plain text files for reading
    // Write exclusively to .jot format
    static var readableContentTypes: [UTType] = [.jotDocument, .rtf, .rtfd, .plainText]
    static var writableContentTypes: [UTType] = [.jotDocument]
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // Try to read as RTF first
        if let attributedString = NSAttributedString(rtf: data, documentAttributes: nil) {
            self.attributedText = attributedString
        }
        // Fall back to RTFD
        else if let attributedString = NSAttributedString(rtfd: data, documentAttributes: nil) {
            self.attributedText = attributedString
        }
        // Fall back to plain text
        else if let string = String(data: data, encoding: .utf8) {
            self.attributedText = NSAttributedString(string: string, attributes: [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.textColor
            ])
        }
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let range = NSRange(location: 0, length: attributedText.length)
        guard let data = attributedText.rtf(from: range, documentAttributes: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

// Make NSAttributedString work with FileDocument by providing Sendable conformance
extension NSAttributedString: @retroactive @unchecked Sendable {}
