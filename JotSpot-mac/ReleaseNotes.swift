//
//  ReleaseNotes.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 1/12/26.
//

import SwiftUI

struct ReleaseNotesType: Hashable {
	let image: String
	let title: String
	let body: String
}

let notes: [ReleaseNotesType] = [
	ReleaseNotesType(image: "sparkles", title: "Redesign", body: "Completely redesigned to support macOS 26 and Apple Silicon")
]

struct ReleaseNotes: View {
	let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	
	
    var body: some View {
		VStack() {
			Text("What's New in " + (appVersion ?? ""))
				.font(.title)
			
			Divider()
			
			ScrollView {
				ForEach(notes, id: \.self) { note in
					HStack {
						Image(systemName: note.image)
							.resizable()
							.frame(width: 32, height: 32)
							.foregroundStyle(.blue)
						
						VStack(alignment: .leading) {
							Text(note.title)
								.font(.title2)
							
							Text(note.body)
						}
						.padding(.leading)
					}
				}
			}
			
			Spacer()
		}
		.padding()
    }
}

#Preview {
    ReleaseNotes()
}
