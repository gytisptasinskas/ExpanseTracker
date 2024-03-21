//
//  SearchView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 05/03/2024.
//

import SwiftUI
import Combine

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var filterText: String = ""
    @State private var selectedCategory: Category? = nil
    
    let searchPublisher = PassthroughSubject<String, Never>()
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    FilterTransactionView(category: selectedCategory, searchText: searchText) { transactions in
                        ForEach(transactions) { transaction in
                            NavigationLink {
                                TransactionView(editTransaction: transaction)
                            } label: {
                                TransactionCardView(transaction: transaction, showsCategory: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(15)
            }
            .overlay {
                ContentUnavailableView("Search Transactions", systemImage: "magnifyingglass")
                    .opacity(filterText.isEmpty ? 1 : 0)
            }
            .onChange(of: searchText) { oldValue, newValue in
                if newValue.isEmpty {
                    filterText = ""
                }
                searchPublisher.send(newValue)
            }
            .onReceive(searchPublisher.debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)) { text in
                filterText = text
            }
            .searchable(text: $searchText)
            .navigationTitle("Search")
            .background(.gray.opacity(0.15))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolBarMenu()
                }
            }
        }
    }
    
    @ViewBuilder
    func ToolBarMenu() -> some View {
        Menu {
            Button {
                selectedCategory = nil
            } label: {
                HStack {
                    Text("Both")
                    
                    if selectedCategory == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            ForEach(Category.allCases, id: \.rawValue) { category in
                Button {
                    selectedCategory = category
                } label: {
                    HStack {
                        Text(category.rawValue)
                        
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "slider.vertical.3")
        }
    }
}

#Preview {
    SearchView()
}
