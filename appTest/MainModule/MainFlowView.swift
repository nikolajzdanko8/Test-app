import SwiftUI
import SwiftData

struct MainFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MainFlowViewModel
    @State private var dependencyContainer: DependencyContainer?
    
    init() {
        _viewModel = State(wrappedValue: MainFlowViewModel(
            foodRepository: MockFoodRepository()
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                dailySummaryView
                inputSectionView
                if viewModel.foodItems.isEmpty {
                    emptyStateView
                } else {
                    foodListSectionView
                }
            }
            .navigationTitle("Calorie calculator")
            .alert("Product duplication", isPresented: $viewModel.showingAddAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("Remove product?", isPresented: Binding(
                get: { viewModel.itemToDelete != nil },
                set: { if !$0 { viewModel.itemToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let item = viewModel.itemToDelete {
                        Task {
                            await viewModel.deleteItem(item)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete? \"\(viewModel.itemToDelete?.name ?? "")\"? This action cannot be undone.")
            }
            .sheet(item: $viewModel.itemToEdit) { item in
                if let container = dependencyContainer {
                    EditFoodItemView(viewModel: container.makeEditFoodItemViewModel(foodItem: item))
                }
            }
            .onAppear {
                if dependencyContainer == nil {
                    dependencyContainer = DependencyContainer(modelContext: modelContext)
                    viewModel = dependencyContainer!.contentViewModel
                }
            }
        }
    }
    
    // MARK: - Subviews
    private var dailySummaryView: some View {
        VStack {
            Text("Summary for the day")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(viewModel.totalCalories)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("kcal")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemGray6))
    }
    
    private var inputSectionView: some View {
        HStack {
            TextField("For example: Orange 12", text: $viewModel.inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.done)
                .onSubmit {
                    Task {
                        await viewModel.addFoodItem()
                    }
                }
            
            Button(action: {
                Task {
                    await viewModel.addFoodItem()
                }
            }) {
                Text("Add")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
    
    private var foodListSectionView: some View {
        List {
            ForEach(viewModel.foodItems) { item in
                FoodItemRowView(
                    item: item,
                    formattedDate: viewModel.formatDate(item.dateAdded)
                )
                .padding(.vertical, 8)
            }
            .onDelete(perform: viewModel.deleteItems)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    if let item = viewModel.foodItems.first {
                        viewModel.itemToDelete = item
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    if let item = viewModel.foodItems.first {
                        viewModel.itemToEdit = item
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "fork.knife.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.4))
                
                VStack(spacing: 8) {
                    Text("No products yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Add your first product using the field above")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
}

// MARK: - Subcomponents
struct FoodItemRowView: View {
    let item: FoodItem
    let formattedDate: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text("Added: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(item.calories) · kcal")
                .font(.title3)
                .foregroundColor(.blue)
        }
    }
}


#Preview {
    MainFlowView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
