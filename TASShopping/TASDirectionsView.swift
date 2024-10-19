//
//  TASDirectionsView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI
import AVFoundation

struct TASDirectionsView: View {
    @State private var synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            Text("Navigating store...")
            Button(action: speakDirection) {
                Text("Next Direction")
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .navigationTitle("Store Navigation")
    }

    func speakDirection() {
        let utterance = AVSpeechUtterance(string: "Proceed to the next aisle for snacks.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

#Preview {
    TASDirectionsView()
}
