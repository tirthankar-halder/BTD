//
//  ContactUs.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-23.
//
import SwiftUI
import AVFoundation
import Foundation


struct ContactUsView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var showAlert = false
    @State private var nameError: String = ""
    @State private var emailError: String = ""
    @State private var messageError: String = ""
    @State private var isSending = false
    @State private var alertMessage: String = ""

    var isFormValid: Bool {
        return nameError.isEmpty &&
               emailError.isEmpty &&
               messageError.isEmpty &&
               !name.isEmpty &&
               !email.isEmpty &&
               !message.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Get in touch")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.yellow)
                
                Text("Have questions? We're here to help. Send us a message and we'll respond as soon as possible.")
                    .foregroundColor(.white.opacity(0.85))
                    .font(.body)
                
                Group {
                    Text("Name *")
                        .foregroundColor(.white)
                        .bold()
                    TextField("Enter your name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.words)
                        .onChange(of: name) { validateName() }
                        if !nameError.isEmpty {
                            Text(nameError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                }
                
                Group {
                    Text("Email *")
                        .foregroundColor(.white)
                        .bold()
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: email) { validateEmail() }
                        if !emailError.isEmpty {
                            Text(emailError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                }
                
                Group {
                    Text("Message")
                        .foregroundColor(.white)
                        .bold()
                    TextEditor(text: $message)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .onChange(of: message) {
                            validateMessage()
                        }
                        if !messageError.isEmpty {
                            Text(messageError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                }
                
                Button(action: {
                    Task {
                        await sendContactMessage()
                    }
                }) {
                    Text("Send Message *")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .disabled(!isFormValid || isSending)
                .opacity((!isFormValid || isSending) ? 0.5 : 1.0)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Thank you!"),
                          message: Text("Your message has been sent."),
                          dismissButton: .default(Text("OK")) )
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    func validateName() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameError = "Name is required."
        } else {
            nameError = ""
        }
    }

    func validateEmail() {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            emailError = "Email is required."
        } else if !trimmed.contains("@") || !trimmed.contains(".") {
            emailError = "Enter a valid email address."
        } else {
            emailError = ""
        }
    }

    func validateMessage() {
        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messageError = "Message cannot be empty."
        } else {
            messageError = ""
        }
    }

    
    func sendContactMessage() async {
        guard let url = URL(string: "https://breakthemdown.onrender.com/contact") else { return }
        print("In Send Contact")
        isSending = true
        let fullMessage = "\(message)\n<This message is from iOS App>"
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "message": fullMessage
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                alertMessage = "Failed to send message. Server error."
                showAlert = true
                isSending = false
                return
            }
            print("Email called")
            print(httpResponse)
            alertMessage = "Message sent successfully!"
            showAlert = true

            // Clear the form
            name = ""
            email = ""
            message = ""

        } catch {
            alertMessage = "Failed to send message: \(error.localizedDescription)"
            showAlert = true
        }

        isSending = false
    }


}

#Preview {
        ContactUsView()
    }
