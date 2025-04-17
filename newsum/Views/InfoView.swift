import SwiftUI

struct InfoView: View {
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView { // Embed in NavigationView for title and dismiss button
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("About Newsum Daily")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 15) {
                        HStack(alignment: .top) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30) // Align icon
                            VStack(alignment: .leading) {
                                Text("Hourly Updates")
                                    .font(.headline)
                                Text("Fresh news summaries are automatically fetched every hour, keeping you informed without constant checking.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack(alignment: .top) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text("Reliable Information")
                                    .font(.headline)
                                Text("We provide concise, AI-generated summaries from trusted sources, helping you grasp key information quickly.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack(alignment: .top) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text("Stay Focused")
                                    .font(.headline)
                                Text("Avoid information overload and endless scrolling. Get the essentials here, stay updated, and reclaim your time.")
                                     .foregroundColor(.secondary)
                           }
                        }
                        
                         Divider()
                        
                        HStack(alignment: .top) {
                             Image(systemName: "paintbrush.pointed")
                                 .font(.title2)
                                 .foregroundColor(.accentColor)
                                 .frame(width: 30)
                             VStack(alignment: .leading) {
                                 Text("Clean & Simple")
                                     .font(.headline)
                                Text("Designed for clarity and ease of use. No clutter, just the news summaries you need.")
                                     .foregroundColor(.secondary)
                             }
                         }
                    }
                    
                    Spacer() // Pushes content up
                }
                .padding()
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // Action to dismiss the sheet
                    }
                }
            }
        }
    }
}

#Preview {
    InfoView()
} 