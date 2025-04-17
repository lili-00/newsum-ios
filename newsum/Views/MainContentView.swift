import SwiftUI

struct MainContentView: View {
    // Use @StateObject to create and manage the ViewModel instance
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.summaries.isEmpty {
                    // Show loading indicator only on initial load
                    ProgressView("Fetching latest news...")
                } else if let errorMessage = viewModel.errorMessage {
                    // Show error message
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.title)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchNews()
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                } else if viewModel.summaries.isEmpty {
                     // Show message if list is empty after loading (and no error)
                     Text("No news summaries available at the moment.")
                         .foregroundColor(.secondary)
                 } else {
                    // Show the list of news summaries
                    List(viewModel.summaries) { summary in
                        // Wrap NewsRow in a NavigationLink
                        NavigationLink {
                            // Destination: The detail view
                            NewsDetailView(summary: summary)
                        } label: {
                            // Label: The row view itself
                            NewsRow(summary: summary)
                        }
                    }
                    .listStyle(.plain) // Use plain list style for a cleaner look
                    .refreshable { // Add pull-to-refresh
                        await viewModel.fetchNews(isRefreshing: true)
                    }
                }
            }
            .navigationTitle("Hourly News") // Set the title for the navigation bar
            .task { // Fetch data when the view first appears
                // Avoid fetching again if data already exists (e.g., after backgrounding)
                if viewModel.summaries.isEmpty {
                    await viewModel.fetchNews()
                }
            }
        }
    }
}

#Preview {
    MainContentView()
}
