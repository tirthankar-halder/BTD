//
//  QueryScreen.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-23.
//

import SwiftUI
import AVFoundation
import Foundation


struct QueryScreen: View {
    @State private var instructions: String = ""
    @State private var isLoading = false
    
    @Binding var responseSteps: [StepItem]
    @Binding var selectedTab: Tab
    @State private var navigateToSteps = false
    
    
    var body: some View {
    ZStack {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("BreakThemDown")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.yellow)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Turn complex Ideas, instructions, habits into clear, doable, steps so that they are easy to understand and act on #BreakThemDown")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextEditor(text: $instructions)
                .frame(height: 150)
                .padding(8)
                .background(Color(red: 12/255, green: 17/255, blue: 15/255))
                .foregroundColor(.black
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow, lineWidth: 1)
                )
            
            
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
        .navigationBarBackButtonHidden()
        .disabled(isLoading) // disables input when loading
        .blur(radius: isLoading ? 3 : 0)
        
        
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
        Task {
            await callFlaskAPI(instructions: instructions)
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
                return
            }

            guard let data = data else {
                print("No Data")
                return
            }

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
        }
        task.resume()
    } //API

} //query screen View


/*
#Preview {
    QueryScreen(responseSteps: Tab.home, selectedTab: Tab.home)
    }*/
