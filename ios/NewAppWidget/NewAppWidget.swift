//
//  NewAppWidget.swift
//  NewAppWidget
//
//  Created by Dolph Hincapie on 12/03/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
      SimpleEntry(date: Date(), message: "******", isHidden: true, expirationDate: Date().addingTimeInterval(0))
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
      let entry = loadEntry()
      completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
      let defaults = UserDefaults(suiteName: "group.bancolombia.homeWidgetPoc")
      let isHidden = defaults?.bool(forKey: "isHidden") ?? true
      let message = defaults?.string(forKey: "widgetMessage") ?? "******"
      let expirationTimestamp = defaults?.double(forKey: "expirationTimestamp") ?? Date().addingTimeInterval(30).timeIntervalSince1970
      let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
      
      let entry = SimpleEntry(date: Date(), message: message, isHidden: isHidden, expirationDate: expirationDate)
      
      let timeline = Timeline(entries: [entry], policy: .after(expirationDate))
      completion(timeline)
  }

  private func getSavedMessage() -> String {
      let defaults = UserDefaults(suiteName: "group.bancolombia.homeWidgetPoc")
      let isHidden = defaults?.bool(forKey: "isHidden") ?? true
      let message = defaults?.string(forKey: "widgetMessage") ?? "******"
      return isHidden ? "******" : message
  }
  
  private func getIsHidden() -> Bool {
      let defaults = UserDefaults(suiteName: "group.bancolombia.homeWidgetPoc")
      return defaults?.bool(forKey: "isHidden") ?? true
  }
  
  private func loadEntry() -> SimpleEntry {
      let defaults = UserDefaults(suiteName: "group.bancolombia.homeWidgetPoc")
      let isHidden = defaults?.bool(forKey: "isHidden") ?? true
      let message = defaults?.string(forKey: "widgetMessage") ?? "******"
      let expirationTimestamp = defaults?.double(forKey: "expirationTimestamp") ?? Date().addingTimeInterval(30).timeIntervalSince1970
      let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
      
      return SimpleEntry(date: Date(), message: message, isHidden: isHidden, expirationDate: expirationDate)
  }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let message: String
    let isHidden: Bool
    let expirationDate: Date
}

struct NewAppWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack(spacing: 10) {
          if Date() < entry.expirationDate {
              Text(timerInterval: Date()...entry.expirationDate, countsDown: true)
                  .font(.caption)
                  .padding(.top, 4)
          } else {
              Text("Expirado")
                  .font(.caption)
                  .padding(.top, 4)
          }
          Text(entry.message)
          Spacer()
          
          HStack(spacing: 15) {
            Button(intent: ToggleVisibilityIntent()) {
                Image(systemName: entry.isHidden ? "eye.slash.fill" : "eye.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding()
                    .background(Color.clear)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .foregroundColor(.black)
            }
            .buttonStyle(.plain)

            Button(intent: BackgroundIntent(message: entry.message)) {
                Image(systemName: "doc.on.doc.fill") // Ícono de Copiar
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding()
                    .background(Color.clear)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .foregroundColor(.black)
            }
            .buttonStyle(.plain)
          }
        }
        .padding()
        .containerBackground(.clear, for: .widget)
        .allowsHitTesting(false)
    }
  
  // Progress Value
  private func progressValue() -> Double {
    let total = entry.expirationDate.timeIntervalSince(entry.date)
    let remaining = entry.expirationDate.timeIntervalSince(Date())
    
    print("🟢 Total: \(total) | Remaining: \(remaining)")

    guard total > 0 else { return 0 }
    
    return max(0, min(1, remaining / total))
  }
  
  private func openApp(action: String) {
  }

  private func copyToClipboard(_ text: String) {
      UIPasteboard.general.string = text
  }
}

struct NewAppWidget: Widget {
    let kind: String = "NewAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NewAppWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NewAppWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        //.supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    NewAppWidget()
} timeline: {
  SimpleEntry(date: .now, message: "******", isHidden: true, expirationDate: Date().addingTimeInterval(0))
}
