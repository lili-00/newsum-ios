//
//  HeadlineDetailView.swift
//  newsum
//
//  Created by Li Li on 4/21/25.
//

import SwiftUI
import SafariServices

// Create a simple placeholder for the destination of the NavigationLink
struct HeadlineDetailView: View {
    let headline: HeadlineSummary
    @State private var showCopiedToast: Bool = false
    @State private var showActionMenu: Bool = false
    @State private var showSafari: Bool = false
    @State private var isButtonPressed: Bool = false
    @AppStorage("textSizeMultiplier") private var textSizeMultiplier: Double = 1.0
    
    var body: some View {
        ZStack {
            ScrollView { // Allow scrolling for potentially long content
                VStack(alignment: .leading, spacing: 15) {
                    Text(headline.title)
                        .font(.system(size: 20 * textSizeMultiplier, weight: .bold))
                        .padding(.top, 4)

                    HStack(spacing: 4) {
                        Text("Source:")
                            .font(.system(size: 13 * textSizeMultiplier))
                            .foregroundColor(.secondary)

                        if let srcURL = URL(string: headline.sourceUrl) {
                            Link(headline.sourceName, destination: srcURL)
                                .font(.system(size: 13 * textSizeMultiplier))
                        } else {
                            Text(headline.sourceName)
                                .font(.system(size: 13 * textSizeMultiplier))
                                .foregroundColor(.secondary)
                        }
                    }

                    Text("Published: \(headline.publishedAt, style: .date) at \(headline.publishedAt, style: .time)")
                        .font(.system(size: 13 * textSizeMultiplier))
                        .foregroundColor(.gray)

                    Divider()
                    
                    // Image placed here - after divider, before content
                    if let imageUrl = headline.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Text(headline.summary)
                        .font(.system(size: 17 * textSizeMultiplier, design: .serif))
                        // Add line spacing for better readability
                        .lineSpacing(5)
                    
                    Divider()

                    if let url = URL(string: headline.url) {
                        Button {
                            // Set button pressed state for animation
                            isButtonPressed = true
                            
                            // Delay the action slightly to allow animation to complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                isButtonPressed = false
                                showSafari = true
                            }
                        } label: {
                            HStack {
                                Text("Read full article")
                                    .font(.system(size: 16 * textSizeMultiplier, weight: .medium))
                                Image(systemName: "safari")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
                        .padding(.top, 8)
                    }

                    Spacer() // Push content to top
                }
                .padding()
            }
            
            // Toast notification
            if showCopiedToast {
                VStack {
                    Spacer()
                    Text("Link copied to clipboard")
                        .font(.system(size: 14 * textSizeMultiplier))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3), value: showCopiedToast)
                .zIndex(1)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCopiedToast = false
                        }
                    }
                }
            }
        }
        .navigationTitle(headline.sourceName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showActionMenu = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
        }
        .confirmationDialog("", isPresented: $showActionMenu, titleVisibility: .hidden) {
            // Copy Link option
            Button {
                UIPasteboard.general.string = headline.url
                showActionMenu = false
                withAnimation {
                    showCopiedToast = true
                }
            } label: {
                HStack {
                    Text("Copy Link")
                    Spacer()
                    Image(systemName: "link")
                }
            }
            
            // Full Article option
            if let url = URL(string: headline.url) {
                Button {
                    showSafari = true
                } label: {
                    HStack {
                        Text("Full Article")
                        Spacer()
                        Image(systemName: "safari")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSafari) {
            if let url = URL(string: headline.url) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// Safari View for opening URLs in Safari
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemBlue
        safariVC.dismissButtonStyle = .done
        safariVC.delegate = context.coordinator
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    // 1. Create a sample HeadlineSummary
    let sampleHeadline = HeadlineSummary(
        title: "Local Community Garden Flourishes This Spring",
        description: "Volunteers celebrate a successful planting season.",
        url: "https://example.com/news/garden",
        imageUrl: "https://images.unsplash.com/photo-1517430816045-df4b7de11d1d", // Example image URL
        summary: "The community garden has sprung to life with dozens of new plantings, thanks to local volunteers...",
        publishedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        summaryGeneratedAt: Calendar.current.date(byAdding: .hour, value: -20, to: Date())!,
        sourceName: "Local Gazette",
        sourceUrl: "https://localgazette.com"
    )

    // 2. Wrap in a NavigationStack so the nav‐title shows
    NavigationStack {
        HeadlineDetailView(headline: sampleHeadline)
    }
}
