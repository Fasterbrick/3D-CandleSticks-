//ContentView.swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: CandleChartViewModel
    
    var body: some View {
        VStack {
            Text("3D Candlestick Chart")
            CandleChartView(viewModel: viewModel)
        }
    }
}
