//_DCandlestickChartApp.swift
import SwiftUI

@main
struct CandleChart3DApp: App {
    @StateObject private var viewModel: CandleChartViewModel
    
    init() {
        let sampleCandles = SampleData.generateSampleCandles(count: 102) // best to match sampleCandles or then repeated
        _viewModel = StateObject(wrappedValue: CandleChartViewModel(candles: sampleCandles))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                // Disable new window creation to prevent multiple instances
            }
        }
    }
}

struct SampleData {
    static func generateSampleCandles(count: Int) -> [Candle] {
        let baseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 23, hour: 9)) ?? Date()
        let sampleCandles = [
            // PATTERN 1: Bearish Engulfing (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(0 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(1 * 86400), open: 1.01450, high: 1.01600, low: 1.00500, close: 1.00600), // Bearish, engulfs previous
            Candle(timestamp: baseDate.addingTimeInterval(2 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 2: Hanging Man (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(3 * 86400), open: 1.01000, high: 1.01100, low: 0.99000, close: 1.01050), // Hanging Man
            Candle(timestamp: baseDate.addingTimeInterval(4 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 3: Shooting Star (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(5 * 86400), open: 1.01000, high: 1.03000, low: 1.00900, close: 1.01050), // Shooting Star
            Candle(timestamp: baseDate.addingTimeInterval(6 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 4: Evening Star (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(7 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(8 * 86400), open: 1.01450, high: 1.01600, low: 1.01400, close: 1.01500), // Small body
            Candle(timestamp: baseDate.addingTimeInterval(9 * 86400), open: 1.01500, high: 1.01600, low: 1.00500, close: 1.00600), // Bearish
            Candle(timestamp: baseDate.addingTimeInterval(10 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 5: Three Black Crows (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(11 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100),
            Candle(timestamp: baseDate.addingTimeInterval(12 * 86400), open: 1.01100, high: 1.01200, low: 1.00700, close: 1.00800),
            Candle(timestamp: baseDate.addingTimeInterval(13 * 86400), open: 1.00800, high: 1.00900, low: 1.00400, close: 1.00500),
            Candle(timestamp: baseDate.addingTimeInterval(14 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 6: Bearish Harami (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(15 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(16 * 86400), open: 1.01300, high: 1.01400, low: 1.01200, close: 1.01300), // Bearish, within previous body
            Candle(timestamp: baseDate.addingTimeInterval(17 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 7: Dark Cloud Cover (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(18 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(19 * 86400), open: 1.01450, high: 1.01600, low: 1.01000, close: 1.01100), // Bearish, closes below midpoint
            Candle(timestamp: baseDate.addingTimeInterval(20 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 8: Bearish Kicker (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(21 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(22 * 86400), open: 1.00800, high: 1.00900, low: 1.00500, close: 1.00600), // Bearish, gaps down
            Candle(timestamp: baseDate.addingTimeInterval(23 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 9: Bearish Abandoned Baby (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(24 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(25 * 86400), open: 1.01500, high: 1.01550, low: 1.01450, close: 1.01500), // Doji, gaps up
            Candle(timestamp: baseDate.addingTimeInterval(26 * 86400), open: 1.01200, high: 1.01300, low: 1.00800, close: 1.00900), // Bearish, gaps down
            Candle(timestamp: baseDate.addingTimeInterval(27 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 10: Bearish Belt Hold (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(28 * 86400), open: 1.01500, high: 1.01500, low: 1.00500, close: 1.00600), // Bearish Marubozu-like
            Candle(timestamp: baseDate.addingTimeInterval(29 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 11: Bearish Marubozu (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(30 * 86400), open: 1.01500, high: 1.01500, low: 1.00500, close: 1.00500), // No shadows
            Candle(timestamp: baseDate.addingTimeInterval(31 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 12: Bearish Counterattack (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(32 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100), // Bearish
            Candle(timestamp: baseDate.addingTimeInterval(33 * 86400), open: 1.01050, high: 1.01200, low: 1.00800, close: 1.00900), // Opens lower, closes lower
            Candle(timestamp: baseDate.addingTimeInterval(34 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 13: Bearish Doji Star (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(35 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(36 * 86400), open: 1.01400, high: 1.01450, low: 1.01350, close: 1.01400), // Doji
            Candle(timestamp: baseDate.addingTimeInterval(37 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 14: Bearish Meeting Lines (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(38 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(39 * 86400), open: 1.01300, high: 1.01400, low: 1.01200, close: 1.01400), // Bearish, closes at same level
            Candle(timestamp: baseDate.addingTimeInterval(40 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 15: Bearish Separating Lines (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(41 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(42 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100), // Bearish, same open
            Candle(timestamp: baseDate.addingTimeInterval(43 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 16: Bearish Side-by-Side Black Lines (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(44 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100), // Bearish
            Candle(timestamp: baseDate.addingTimeInterval(45 * 86400), open: 1.01050, high: 1.01100, low: 1.00800, close: 1.00900), // Bearish, gaps down
            Candle(timestamp: baseDate.addingTimeInterval(46 * 86400), open: 1.01050, high: 1.01100, low: 1.00800, close: 1.00900), // Similar bearish
            Candle(timestamp: baseDate.addingTimeInterval(47 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 17: Bearish Tasuki Gap (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(48 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100), // Bearish
            Candle(timestamp: baseDate.addingTimeInterval(49 * 86400), open: 1.00900, high: 1.01000, low: 1.00800, close: 1.00900), // Bearish, gaps down
            Candle(timestamp: baseDate.addingTimeInterval(50 * 86400), open: 1.01000, high: 1.01700, low: 1.00900, close: 1.01600), // Bullish, doesn't fill gap
            Candle(timestamp: baseDate.addingTimeInterval(51 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 18: Bearish Three-Line Strike (4 candles)
            Candle(timestamp: baseDate.addingTimeInterval(52 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100),
            Candle(timestamp: baseDate.addingTimeInterval(53 * 86400), open: 1.01100, high: 1.01200, low: 1.00800, close: 1.00900),
            Candle(timestamp: baseDate.addingTimeInterval(54 * 86400), open: 1.00900, high: 1.01000, low: 1.00600, close: 1.00700),
            Candle(timestamp: baseDate.addingTimeInterval(55 * 86400), open: 1.00700, high: 1.01200, low: 1.00650, close: 1.01100), // Bullish, engulfs previous three
            Candle(timestamp: baseDate.addingTimeInterval(56 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 19: Bearish Breakaway (5 candles)
            Candle(timestamp: baseDate.addingTimeInterval(57 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(58 * 86400), open: 1.01400, high: 1.01600, low: 1.01300, close: 1.01500), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(59 * 86400), open: 1.01500, high: 1.01700, low: 1.01400, close: 1.01600), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(60 * 86400), open: 1.01600, high: 1.01800, low: 1.01500, close: 1.01700), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(61 * 86400), open: 1.01700, high: 1.01800, low: 1.01200, close: 1.01300), // Bearish, closes within first candle
            Candle(timestamp: baseDate.addingTimeInterval(62 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 20: Bearish Ladder Top (5 candles)
            Candle(timestamp: baseDate.addingTimeInterval(63 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(64 * 86400), open: 1.01400, high: 1.01600, low: 1.01300, close: 1.01500), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(65 * 86400), open: 1.01500, high: 1.01700, low: 1.01400, close: 1.01600), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(66 * 86400), open: 1.01600, high: 1.01800, low: 1.01500, close: 1.01700), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(67 * 86400), open: 1.01700, high: 1.01800, low: 1.01400, close: 1.01500), // Bearish, shooting star-like
            Candle(timestamp: baseDate.addingTimeInterval(68 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 21: Bearish Falling Three Methods (5 candles)
            Candle(timestamp: baseDate.addingTimeInterval(69 * 86400), open: 1.01500, high: 1.01600, low: 1.01000, close: 1.01100), // Bearish
            Candle(timestamp: baseDate.addingTimeInterval(70 * 86400), open: 1.01100, high: 1.01200, low: 1.01000, close: 1.01150), // Small bullish
            Candle(timestamp: baseDate.addingTimeInterval(71 * 86400), open: 1.01150, high: 1.01250, low: 1.01100, close: 1.01200), // Small bullish
            Candle(timestamp: baseDate.addingTimeInterval(72 * 86400), open: 1.01200, high: 1.01300, low: 1.01150, close: 1.01250), // Small bullish
            Candle(timestamp: baseDate.addingTimeInterval(73 * 86400), open: 1.01250, high: 1.01300, low: 1.00800, close: 1.00900), // Bearish, closes lower
            Candle(timestamp: baseDate.addingTimeInterval(74 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 22: Bearish Unique Three River Top (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(75 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(76 * 86400), open: 1.01400, high: 1.01600, low: 1.01300, close: 1.01500), // Bullish, new high
            Candle(timestamp: baseDate.addingTimeInterval(77 * 86400), open: 1.01500, high: 1.01550, low: 1.01400, close: 1.01450), // Bearish, small body
            Candle(timestamp: baseDate.addingTimeInterval(78 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 23: Bearish Stick Sandwich (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(79 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(80 * 86400), open: 1.01400, high: 1.01450, low: 1.01350, close: 1.01400), // Doji-like
            Candle(timestamp: baseDate.addingTimeInterval(81 * 86400), open: 1.01400, high: 1.01450, low: 1.00900, close: 1.01000), // Bearish, closes at first close
            Candle(timestamp: baseDate.addingTimeInterval(82 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 24: Bearish Homing Pigeon (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(83 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(84 * 86400), open: 1.01300, high: 1.01400, low: 1.01200, close: 1.01300), // Small bullish, within first body
            Candle(timestamp: baseDate.addingTimeInterval(85 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 25: Bearish Matching High (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(86 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(87 * 86400), open: 1.01400, high: 1.01500, low: 1.01300, close: 1.01400), // Bullish, same high
            Candle(timestamp: baseDate.addingTimeInterval(88 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 26: Bearish Tri-Star (3 candles)
            Candle(timestamp: baseDate.addingTimeInterval(89 * 86400), open: 1.01400, high: 1.01450, low: 1.01350, close: 1.01400), // Doji
            Candle(timestamp: baseDate.addingTimeInterval(90 * 86400), open: 1.01500, high: 1.01550, low: 1.01450, close: 1.01500), // Doji, higher
            Candle(timestamp: baseDate.addingTimeInterval(91 * 86400), open: 1.01400, high: 1.01450, low: 1.01350, close: 1.01400), // Doji, lower
            Candle(timestamp: baseDate.addingTimeInterval(92 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 27: Bearish Tweezers Top (2 candles)
            Candle(timestamp: baseDate.addingTimeInterval(93 * 86400), open: 1.01000, high: 1.01500, low: 1.00900, close: 1.01400), // Bullish
            Candle(timestamp: baseDate.addingTimeInterval(94 * 86400), open: 1.01400, high: 1.01500, low: 1.01300, close: 1.01350), // Bearish, same high
            Candle(timestamp: baseDate.addingTimeInterval(95 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 28: Bearish Gravestone Doji (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(96 * 86400), open: 1.01000, high: 1.01500, low: 1.01000, close: 1.01000), // Gravestone Doji
            Candle(timestamp: baseDate.addingTimeInterval(97 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 29: Bearish Long-Legged Doji (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(98 * 86400), open: 1.01000, high: 1.01500, low: 1.00500, close: 1.01000), // Long-Legged Doji
            Candle(timestamp: baseDate.addingTimeInterval(99 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral

            // PATTERN 30: Bearish Spinning Top (1 candle)
            Candle(timestamp: baseDate.addingTimeInterval(100 * 86400), open: 1.01000, high: 1.01200, low: 1.00800, close: 1.00950), // Small body, large shadows
            Candle(timestamp: baseDate.addingTimeInterval(101 * 86400), open: 1.02000, high: 1.02000, low: 1.02000, close: 1.02000), // Neutral
        ]

        
        if count <= sampleCandles.count {
            return Array(sampleCandles.prefix(count))
        } else {
            return (0..<count).map { i in
                sampleCandles[i % sampleCandles.count] // Repeat pattern if more candles needed
            }
        }
    }
}
