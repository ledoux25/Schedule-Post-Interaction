//
//  ContentView.swift
//  Schedule Button Interaction
//
//  Created by Sanguo Joseph Ledoux on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State private var isScheduling: Bool = false
    @State private var selectedDate: Date = .now
    @Namespace private var animation

    // Centralized constants (internal so subviews can reference ContentView.UI)
    enum UI {
        static let cardCorner: CGFloat = 24
        static let strokeOpacity: Double = 0.2
        static let controlHeight: CGFloat = 40
        static let controlPaddingTrailing: CGFloat = 35
        static let animationDuration: TimeInterval = 0.48
    }


    var body: some View {
        VStack {
            ZStack {
                ScheduledInfoBanner(date: selectedDate, isVisible: isScheduling)
                VStack {
                    TextField("What's up?", text: $text)
                        .font(.title3.weight(.medium))

                    Spacer()

                    VStack(spacing: 8) {
                        if isScheduling {
                            SchedulingPickerBar(selectedDate: $selectedDate) {
                                withAnimation(.bouncy(duration: UI.animationDuration, extraBounce: 0.1)) {
                                    isScheduling.toggle()
                                }
                            }
                            .transition(
                                .asymmetric(
                                    insertion: .offset(y: 40).combined(with: .opacity),
                                    removal: .offset(y: 40).combined(with: .opacity)
                                )
                            )
                        }

                        ActionButtons(
                            isScheduling: isScheduling,
                            animation: animation,
                            onCalendarTap: {
                                withAnimation(.bouncy(duration: UI.animationDuration, extraBounce: 0.1)) {
                                    isScheduling = true
                                }
                            },
                            onPost: {},
                            onSchedule: {}
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, maxHeight: 160, alignment: .top)
                .padding()
                .background(.white)
                .clipShape(.rect(cornerRadius: UI.cardCorner))
                .overlay(
                    RoundedRectangle(cornerRadius: UI.cardCorner + 4)
                        .stroke(.black.opacity(UI.strokeOpacity))
                )
            }
        }
        .padding()
    }
}



private struct ScheduledInfoBanner: View {
    let date: Date
    let isVisible: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Will be posted on \(date.dayMonthString), \(date.hourMinuteString)")
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, maxHeight: 160, alignment: .top)
        .padding(.bottom, 12)
        .background(Color.gray.opacity(0.07))
        .overlay(
            RoundedRectangle(cornerRadius: ContentView.UI.cardCorner)
                .stroke(.black.opacity(ContentView.UI.strokeOpacity))
        )
        .clipShape(.rect(cornerRadius: ContentView.UI.cardCorner))
        .offset(y: isVisible ? 52 : 0)
        .opacity(isVisible ? 1 : 0)
        .accessibilityHidden(!isVisible)
    }
}

private struct SchedulingPickerBar: View {
    @Binding var selectedDate: Date
    var onClose: () -> Void

    var body: some View {
        ZStack {
            
            HStack {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, maxHeight: 37.8, alignment: .trailing)
            .padding(.trailing, 12)
            .background(.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: ContentView.UI.cardCorner))
            .foregroundStyle(.gray)
            .font(.callout.bold())
            .contentShape(.rect)
            .onTapGesture(perform: onClose)
            .accessibilityLabel("Close scheduling")

            
            HStack {
                
                HStack(spacing: 6) {
                    ZStack {
                        Text(selectedDate.dayMonthYearString)
                            .allowsHitTesting(false)
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .colorMultiply(.clear)
                            .zIndex(2)
                            .frame(maxWidth: 120)
                            .scaleEffect(1.4)
                            .labelsHidden()
                            .accessibilityLabel("Select date")
                    }
                    .fixedSize(horizontal: true, vertical: true)

                    Image(systemName: "chevron.down")
                        .font(.callout.bold())
                        .disabled(true)
                        .accessibilityHidden(true)
                }

                Divider()

            
                HStack {
                    ZStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                            .colorMultiply(.clear)
                            .zIndex(1)
                            .scaleEffect(1.6)
                            .frame(maxWidth: 120, maxHeight: 40)
                            .offset(x: 8)
                            .labelsHidden()
                            .accessibilityLabel("Select time")

                        Text(selectedDate.hourMinuteString)
                            .offset(x: -12)
                            .allowsHitTesting(false)
                    }
                    .fixedSize(horizontal: true, vertical: true)

                    Image(systemName: "chevron.down")
                        .font(.callout.bold())
                        .accessibilityHidden(true)

                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 38)
            .background(.white)
            .clipShape(.rect(cornerRadius: ContentView.UI.cardCorner))
            .overlay(
                RoundedRectangle(cornerRadius: ContentView.UI.cardCorner)
                    .stroke(.gray.opacity(0.3))
            )
            .foregroundStyle(.gray)
            .font(.headline)
            .padding(.trailing, ContentView.UI.controlPaddingTrailing)
        }
        .frame(maxWidth: .infinity, maxHeight: ContentView.UI.controlHeight)
        .clipShape(.rect(cornerRadius: ContentView.UI.cardCorner))
        .foregroundStyle(.gray.opacity(0.8))
    }
}

private struct ActionButtons: View {
    let isScheduling: Bool
    let animation: Namespace.ID
    var onCalendarTap: () -> Void
    var onPost: () -> Void
    var onSchedule: () -> Void

    var body: some View {
        if !isScheduling {
            HStack {
                Image(systemName: "calendar")
                    .padding(13)
                    .background(Color.gray.opacity(0.15))
                    .foregroundStyle(.black.opacity(0.55))
                    .clipShape(.circle)
                    .contentShape(.circle)
                    .onTapGesture(perform: onCalendarTap)
                    .matchedGeometryEffect(id: "button", in: animation)
                    .accessibilityLabel("Schedule")

                Button("Post", action: onPost)
                    .frame(maxWidth: 100)
                    .padding(12)
                    .background(.black)
                    .foregroundStyle(.white)
                    .font(.title3.weight(.semibold))
                    .clipShape(.rect(cornerRadius: 28))
                    .accessibilityLabel("Post now")
            }
        } else {
            Button("Schedule", action: onSchedule)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.black)
                .foregroundStyle(.white)
                .font(.title3.weight(.semibold))
                .clipShape(.rect(cornerRadius: 28))
                .matchedGeometryEffect(id: "button", in: animation)
                .accessibilityLabel("Confirm schedule")
        }
    }
}


private extension Date {
    var dayMonthYearString: String {
        formatted(.dateTime.day().month().year())
    }
    var dayMonthString: String {
        formatted(.dateTime.day().month())
    }
    var hourMinuteString: String {
        formatted(.dateTime.hour().minute())
    }
}

#Preview {
    ContentView()
}
