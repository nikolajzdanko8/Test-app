import SwiftUI

struct EditFoodItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: EditFoodItemViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Product name", text: $viewModel.name)
                    TextField("Calories", text: $viewModel.calories)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Save changes") {
                        Task {
                            await viewModel.saveChanges()
                            if !viewModel.showErrorAlert {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || !viewModel.hasChanges)
                }
            }
            .navigationTitle("Change product")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
