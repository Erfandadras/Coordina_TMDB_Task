//
//  AuthorInfoView.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import SwiftUI

/// View displaying app information and author details
struct AuthorInfoView: View {
    /// Coordinator for manual navigation management
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon and Title Section
                VStack(spacing: 16) {
                    // App Name
                    Text("TMDB Movies")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // App Version
                    Text(Utils.versionString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Divider()
                
                // Author Information Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Developer Information", systemImage: "person.circle.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        AuthorInfoRow(
                            icon: "person.fill",
                            title: "Name",
                            value: "Erfan Dadras",
                            color: .blue
                        )
                        
                        AuthorInfoRow(
                            icon: "envelope.fill",
                            title: "Email",
                            value: "erfandadras@gmail.com",
                            color: .green,
                            isInteractive: true,
                            action: {
                                openEmail()
                            }
                        )
                        
                        AuthorInfoRow(
                            icon: "link",
                            title: "GitHub",
                            value: "github.com/erfandadras",
                            color: .purple,
                            isInteractive: true,
                            action: {
                                openGitHub()
                            }
                        )
                        
                        AuthorInfoRow(
                            icon: "briefcase.fill",
                            title: "Role",
                            value: "iOS Developer",
                            color: .orange
                        )
                        
                        AuthorInfoRow(
                            icon: "location.fill",
                            title: "Location",
                            value: "?!",
                            color: .red
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                
                Divider()
                
                // App Information Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("App Information", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        AuthorInfoRow(
                            icon: "calendar",
                            title: "Release Date",
                            value: "Jun 2025",
                            color: .blue
                        )
                        
                        AuthorInfoRow(
                            icon: "hammer.fill",
                            title: "Built with",
                            value: "SwiftUI & Combine",
                            color: .green
                        )
                        
                        AuthorInfoRow(
                            icon: "server.rack",
                            title: "API",
                            value: "The Movie Database (TMDB)",
                            color: .yellow
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                
                // Copyright Section
                VStack(spacing: 8) {
                    Text(" 2025 Erfan Dadras")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Made with SwiftUI for learning purposes")
                        .font(.caption2)
                        .foregroundColor(.teal)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Private Methods
    private func openEmail() {
        print("open email")
        if let url = URL(string: "mailto:erfandadras@gmail.com") {
            print("open email2")
            UIApplication.shared.open(url)
        }
    }
    
    private func openGitHub() {
        print("open web site")
        if let url = URL(string: "https://github.com/erfandadras") {
            print("open web site2")
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views
/// Reusable row component for displaying author information
struct AuthorInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var isInteractive: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(isInteractive ? color : .primary)
            }
            
            Spacer()
            
            // Interactive indicator
            if isInteractive {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(.secondarySystemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            if isInteractive {
                action?()
            }
        }
    }
}
