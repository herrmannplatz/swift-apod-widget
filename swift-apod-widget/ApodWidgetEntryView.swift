//
//  swift_apod_widget.swift
//  swift-apod-widget
//
//  Created by rehez on 11.07.20.
//

import WidgetKit
import SwiftUI
import Intents

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

struct Provider: IntentTimelineProvider {
    public func snapshot(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "foo", image: UIImage(named: "apod"), configuration: configuration)
        completion(entry)
    }

    public func timeline(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        ApodApi().getCurrent { (result) in
            switch result {
                case .success(let apod):
                    URLSession.shared.dataTask(with: NSURL(string: apod.url)! as URL, completionHandler: { (data, response, error) -> Void in

                        if error != nil {
                            print(error ?? "error")
                            return
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            let entries = [SimpleEntry(date: apod.date, title: apod.title, image: UIImage(data: data!), configuration: configuration)]
                            let timeline = Timeline(entries: entries, policy: .atEnd)
                            completion(timeline)
                        })

                    }).resume()
                    
                    
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let title: String
    public let image: UIImage?
    public let configuration: ConfigurationIntent
}

struct PlaceholderView : View {
    var body: some View {
        Text("Placeholder View")
    }
}

struct ApodWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(entry.date.getFormattedDate(format: "MMMM dd,yyyy"))
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.light)
            
            Text(entry.title.uppercased())
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.semibold)
            
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
        .background(Image("apod")
                        .resizable()
                        .scaledToFill()
                        .brightness(-0.1))
    }
}

@main
struct swift_apod_widget: Widget {
    private let kind: String = "swift_apod_widget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(), placeholder: PlaceholderView()) { entry in
            ApodWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Astronomy Picture of the Day")
        .description("Each day a different image or photograph of our fascinating universe is featured, along with a brief explanation written by a professional astronomer.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct swift_apod_widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ApodWidgetEntryView(entry: SimpleEntry(date: Date(), title: "foo", image: UIImage(named: "apod"),configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            ApodWidgetEntryView(entry: SimpleEntry(date: Date(), title: "foo", image: UIImage(named: "apod"),configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
