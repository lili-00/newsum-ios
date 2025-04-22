import SwiftUI

struct HeadlineListView: View {
    // Use @StateObject to create and manage the ViewModel instance
    @StateObject private var viewModel = HeadlineViewModel()

    var body: some View {
        NavigationView { // Use NavigationView to manage the title and potential navigation
            ScrollView { // Use ScrollView for the scrolling effect
                LazyVStack(alignment: .leading, spacing: 16) { // LazyVStack for performance
                    // Large Title that scrolls
                    Text("Newsum")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top) // Add some padding at the top

                    // Content based on ViewModel state
                    if viewModel.isLoading {
                        ProgressView("Loading Headlines...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                            Text("Error Loading Headlines")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task {
                                    await viewModel.loadHeadlines()
                                }
                            }
                            .padding(.top)
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else if viewModel.headlines.isEmpty {
                        Text("No headlines available.")
                             .foregroundColor(.secondary)
                             .frame(maxWidth: .infinity, alignment: .center)
                             .padding()
                    } else {
                        // Display headlines using HeadlineRow
                        ForEach(viewModel.headlines) { headline in
                            HeadlineRow(headline: headline)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            // Hide the default navigation bar title area since we have our own title in the ScrollView
            .navigationBarHidden(true) 
            // Task modifier to load headlines when the view appears
            .task {
                // Avoid reloading if headlines are already loaded
                if viewModel.headlines.isEmpty {
                    await viewModel.loadHeadlines()
                }
            }
            // Add a refreshable modifier for pull-to-refresh
            .refreshable {
                 await viewModel.loadHeadlines()
            }
        }
         // Prevent the NavigationView from constraining the content vertically on iPad/larger devices
        .navigationViewStyle(.stack) 
    }
}

#Preview {
    HeadlineListView()
} 