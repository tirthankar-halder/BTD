//
//  AboutUs.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-23.
//
import SwiftUI
import AVFoundation
import Foundation

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Image("DyazLogo") // Replace "logo" with the actual name of your asset
                    .resizable()
                    .aspectRatio(contentMode: .fill) // or .fill, depending on your design
                    .frame(height: 100)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("At DYAZ, we believe the future of technology lies at the intersection of human ingenuity and autonomous intelligence.")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Group {
                    Text("Our Story")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)
                        .padding(.bottom, 4)
                    
                    Text("""
                    Founded by a team of AI researchers, software architects, and creative futurists, DYAZ was born from a shared passion: to build systems that don't just execute code, but learn, adapt, and evolve alongside the people who use them.
                    """)
                    .foregroundColor(.white)
                }
                
                Group {
                    Text("Our Mission")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)
                        .padding(.bottom, 4)
                    
                    Text("""
                    To pioneer self‑evolving AI platforms that seamlessly amplify human creativity, drive sustainable innovation, and unlock limitless possibilities in a hyper‑connected world.
                    """)
                    .foregroundColor(.white)
                }
                
                Group {
                    Text("Our Values")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)
                        .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Human‑Centered AI")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Our platforms are built around your workflow, not ours. We listen, iterate, and co‑create so that AI feels like an extension of your own creative spark.")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Relentless Innovation")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("We're not satisfied with incremental improvements. Every line of code, every model we train, is driven by a desire to redefine what's possible.")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Integrity by Design")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Data privacy, transparent decision‑making, and fairness are baked into our architecture—no afterthoughts, no hidden black boxes.")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden()
    }
} //About Us

#Preview {
        AboutUsView()
    }

