//
//  QueryScreen.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-23.
//

import SwiftUI
import AVFoundation
import Foundation

struct PulsingDot: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 12, height: 12)
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: scale)
            .onAppear {
                scale = 1.5
            }
    }
}


struct QueryScreen: View {
    @State private var instructions: String = ""
    @State private var isLoading = false
    
    @State private var isRecording = false
    @State private var recordingTime = 0
    @State private var timer: Timer?
    @State private var selectedLanguage = "en-US"
    
    @Binding var responseSteps: [StepItem]
    @Binding var selectedTab: Tab
    @State private var navigateToSteps = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @StateObject private var recognizer = SpeechRecognizer(locale: Locale(identifier: "en-US"))

    
    var body: some View {
    ZStack {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("BreakThemDown")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.yellow)
                .frame(maxWidth: .infinity, alignment: .center)
                .layoutPriority(1)
            
            Text("Turn complex Ideas, instructions, habits into clear, doable, steps so that they are easy to understand and act on #BreakThemDown")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            
           
            TextEditor(text: $instructions)
                .frame(height: 150)
                .padding(8)
  //              .background(Color(red: 12/255, green: 17/255, blue: 15/255))
                .background(Color.white)          // Force white background
                .foregroundColor(.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow, lineWidth: 5)
                )
                .environment(\.colorScheme, .light) 
            
            if isRecording {
                            Text("Recording: \(recordingTime)s")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }

                        HStack {
                            Button(action: {
                                recognizer.requestPermission()

                                if isRecording {
                                    recognizer.stopTranscribing()
                                    timer?.invalidate()
                                    timer = nil
                                } else {
                                    let originalText = self.instructions
                                    recognizer.onResult = { newText in
                                        self.instructions = originalText + " " + newText
                                    }
                                    recognizer.startTranscribing()
                                    recordingTime = 0
                                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                        recordingTime += 1
                                    }
                                }

                                isRecording.toggle()
                            }) {
                                HStack {
                                    Image(systemName: isRecording ? "mic.fill" : "mic")
                                        .font(.title)
                                        .foregroundColor(isRecording ? .red : .blue)

                                    if isRecording {
                                        PulsingDot()
                                    }
                                }
                                .padding()
                            }

                           
                        }

                       
                    
            
            
            Button(action: {
                
                submitRequest()
            }        )
            {
                Text("Submit Request")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            Spacer()
            
            
        }
        .padding()
        .background(Color(red: 12/255, green: 17/255, blue: 15/255))
        .navigationBarHidden(true)
        .disabled(isLoading) // disables input when loading
        .blur(radius: isLoading ? 3 : 0)
        .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        
        
        // Loading overlay
        
        if isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                
                ProgressView("AI is working hard to break it down...Hang tight!!")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .animation(.easeInOut, value: isLoading)
        }
    }
        }
        
        // Method to trigger the API call
    func submitRequest() {
        DispatchQueue.main.async {
            withAnimation {
                self.responseSteps = []
                self.navigateToSteps = false
                self.navigateToSteps = true
            }
            self.isLoading = true
        }
        print("Instructions submitted: \(instructions) Spinner value: \(isLoading)")
        pingBackendIfNeeded {
            Task {
            await callFlaskAPI(instructions: instructions)
            }
            
        }
    }
        
        
        // **** function for call API backend
    func callFlaskAPI(instructions: String) async {
        
       
        guard let url = URL(string: "https://breakthemdown.onrender.com/breakdown") else {
            DispatchQueue.main.async {
                self.isLoading = false

            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["instruction": instructions]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false // ✅ Hide spinner when done
            }

            if let error = error {
                print("Error:", error)
                DispatchQueue.main.async {
                            self.alertTitle = "Network Error"
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                return
            }

            guard let data = data else {
                print("No Data")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response object")
                    return
                }
            
// Handle HTTP Status
            switch httpResponse.statusCode {
            case 200:
                //Successful Response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let steps = json["steps"] as? [String] {
                        DispatchQueue.main.async {
                            self.responseSteps = steps.map { StepItem(text: $0) }
                            self.navigateToSteps = true
                            self.isLoading = false
                            self.selectedTab = .results
                        }
                    } else {
                        print("Invalid JSON format")
                        self.isLoading = false
                    }
                } catch {
                    print("JSON Error:", error)
                    self.isLoading = false
                }
            
            case 400:
                print("400 Bad Request - Possibly filtered content")
                DispatchQueue.main.async {
                            self.alertTitle = "Content Blocked"
                            self.alertMessage = "Some content was flagged and cannot be processed."
                            self.showAlert = true
                        }
            
            default:
                print("Unhandled HTTP status: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                            self.alertTitle = "Server Error"
                            self.alertMessage = "Unexpected server response: \(httpResponse.statusCode)"
                            self.showAlert = true
                        }
            }
        }
        task.resume()
    } //API

} //query screen View

func pingBackendIfNeeded(completion: @escaping () -> Void) {
    guard let url = URL(string: "https://breakthemdown.onrender.com/ping") else {
        completion()
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 5 // Keep it short, it's just to wake up

    URLSession.shared.dataTask(with: request) { _, _, _ in
        // No matter what happens, continue with actual call
        completion()
    }.resume()
}
/*
#Preview {
    QueryScreen(responseSteps: Tab.home, selectedTab: Tab.home)
    }*/
