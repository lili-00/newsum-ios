import SwiftUI

struct MainContentView: View {
    // Use @StateObject to create and manage the ViewModel instance
    @StateObject private var viewModel = NewsViewModel()
    // State to control the info sheet presentation
    @State private var showingInfoSheet = false

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
                        // Wrap the row in a NavigationLink
                        NavigationLink(destination: SummaryDetailView(summary: summary)) {
                            NewsRow(summary: summary)
                        }
                    }
                    .listStyle(.plain) // Use plain list style for a cleaner look
                    .refreshable { // Add pull-to-refresh
                        await viewModel.fetchNews(isRefreshing: true)
                    }
                }
            }
            .navigationTitle("Newsum Daily") // Set the title for the navigation bar
            // Add toolbar for the info button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfoSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .task { // Fetch data when the view first appears
                // Avoid fetching again if data already exists (e.g., after backgrounding)
                if viewModel.summaries.isEmpty {
                    await viewModel.fetchNews()
                }
            }
            // Present the sheet when showingInfoSheet is true
            .sheet(isPresented: $showingInfoSheet) {
                InfoView()
            }
        }
    }
}

#Preview {
    MainContentView()
}
