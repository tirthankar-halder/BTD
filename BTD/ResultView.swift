//
//  ResultView.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-23.
//

import SwiftUI
import AVFoundation
import Foundation

struct ResultView: View {
    // @State private var steps: [StepItem]
    @Binding var steps: [StepItem]  // Use binding now
    let synthesizer = AVSpeechSynthesizer()

    /*init(steps: [String]) {
        _steps = State(initialValue: steps.map { StepItem(text: $0) })
    }*/
    var allDone: Bool {
        !steps.isEmpty && steps.allSatisfy { $0.isDone }
    }


    var body: some View {
        ZStack {
                Color.black
                    .ignoresSafeArea()
                    if steps.isEmpty {
                        Text("No Steps Available")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach($steps) { $step in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(step.text)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .lineLimit(step.isExpanded ? nil : 2)
                                                .onTapGesture {
                                                    step.isExpanded.toggle()
                                                }
                                            
                                            Spacer()
                                            
                                            // Speech button
                                            Button(action: {
                                                speak(text: step.text)
                                            }) {
                                                Image(systemName: "speaker.wave.2.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                            
                                            // Done toggle
                                            Button(action: {
                                                step.isDone.toggle()
                                            }) {
                                                Image(systemName: step.isDone ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(step.isDone ? .green : .gray)
                                            }
                                        }
                                        
                                        if step.isExpanded {
                                            Text("Tap again to collapse.")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    //      .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                                    .background(Color(red: 60/255, green: 60/255, blue: 60/255))
                                    .navigationBarBackButtonHidden()
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                }
                                
                            }
                            .padding()
                            .navigationBarBackButtonHidden()
                        }
                        .background(Color.black.ignoresSafeArea())
                        .navigationBarBackButtonHidden()
                        // Overlay "All Done" celebration
                        if allDone {
                            VStack {
                                Text("🎉 All Done! 🎉")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(16)
                                    .shadow(radius: 10)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.4), value: allDone)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.6).ignoresSafeArea())
                        }
                    }
        } //ZStack
        .navigationBarBackButtonHidden()
        
    } // Body

    func speak(text: String) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure AVAudioSession: \(error)")
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

}




