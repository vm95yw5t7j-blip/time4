import SwiftUI
import WidgetKit

private struct Time4ComplicationEntry: TimelineEntry {
    let date: Date
}

private struct Time4ComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> Time4ComplicationEntry {
        Time4ComplicationEntry(date: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (Time4ComplicationEntry) -> Void
    ) {
        completion(Time4ComplicationEntry(date: Date()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Time4ComplicationEntry>) -> Void
    ) {
        completion(Timeline(entries: [Time4ComplicationEntry(date: Date())], policy: .never))
    }
}

private struct Time4Mark: View {
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.06, to: 0.21)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0.31, to: 0.46)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0.56, to: 0.71)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0.81, to: 0.96)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: "play.fill")
                .font(.system(size: 12, weight: .bold))
                .offset(x: 1)
        }
        .foregroundStyle(.orange)
        .widgetAccentable()
    }
}

private struct Time4ComplicationView: View {
    @Environment(\.widgetFamily) private var family

    let entry: Time4ComplicationEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            Time4Mark()
                .padding(5)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        case .accessoryRectangular:
            HStack(spacing: 8) {
                Time4Mark()
                    .frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Time4")
                        .font(.headline)
                    Text("タップして開く")
                        .font(.caption2)
                }
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
        case .accessoryInline:
            Label("Time4", systemImage: "timer")
                .containerBackground(for: .widget) {
                    Color.clear
                }
        case .accessoryCorner:
            Time4Mark()
                .padding(4)
                .widgetLabel {
                    Text("Time4")
                }
                .containerBackground(for: .widget) {
                    Color.clear
                }
        default:
            Text("Time4")
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
    }
}

@main
struct Time4WatchWidget: Widget {
    private let kind = "Time4WatchComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Time4ComplicationProvider()) { entry in
            Time4ComplicationView(entry: entry)
        }
        .configurationDisplayName("Time4")
        .description("文字盤からTime4をすぐに開きます。")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner,
        ])
    }
}
