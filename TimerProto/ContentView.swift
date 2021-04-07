//
//  ContentView.swift
//  TimerProto
//
//  Created by 浜田諒 on 2021/03/18.
//

import SwiftUI
import AudioToolbox

struct TimerView: View {
    @Binding var timerScreenShow:Bool
    @State var timeVal:Double
    @State var diff:Double = Double(0)

    @State var timer:Timer?

    var body: some View {

        Group{
            ZStack {
                ZStack {
                    Circle()
                        .stroke(Color(.darkGray), style: StrokeStyle(lineWidth: 30))
                        .scaledToFit()
                        .padding(50)

                    Circle()
                        .trim(from: 0, to: CGFloat(self.diff / (self.timeVal + self.diff)))
                        .stroke(Color(.cyan), style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .bevel))
                        .scaledToFit()
                        //輪郭線の開始位置を12時の方向にする
                        .rotationEffect(Angle(degrees: -90))
                        .padding(50)

                }

                if timeVal >= 0 {
                    VStack {
                        Text("\(getMinuteSecond(timeVal: self.timeVal))").font(.system(size: 40))
                            .onAppear() {
                                self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                                    if self.timeVal >= 0 {
                                        self.timeVal -= 0.05
                                        self.diff += Double(0.05)
                                    }
                                }
                            }
                        Button(action: {
                            self.timer?.invalidate()
                            self.timerScreenShow = false
                            self.timeVal = 1
                            self.diff = 0
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(Color.red)
                        })
                        .padding(.top)
                    }
                } else {
                    Button(action: {
                        self.timer?.invalidate()
                        self.timerScreenShow = false
                        self.timeVal = 1
                        self.diff = 0
                    }, label: {
                        Text("Done!")
                            .font(.title)
                            .foregroundColor(Color.green)
                    }).onAppear() {
                        AudioServicesPlayAlertSoundWithCompletion(1304, nil)
                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
                    }
                }
            }
        }.onDisappear() {
            self.timer?.invalidate()
            self.timeVal = 1
            self.diff = 0
        }
    }

    private func getMinuteSecond(timeVal:Double) -> String {
        let plusOneSecond = timeVal + Double(1)
        var minute = String(Int(plusOneSecond) / 60)
        if (Int(plusOneSecond) / 60) / 10 == 0 {
            minute = "0" + minute
        }
        var second = String(Int(plusOneSecond) % 60)
        if (Int(plusOneSecond) % 60) / 10 == 0 {
            second = "0" + second
        }
        return minute + ":" + second
    }
}

struct ContentView: View {
    @State var minuteVal:Int = 0
    @State var secondVal:Int = 1
    @State var timerScreenShow:Bool = false

    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                VStack {
                    Text("Timer \(Int(self.minuteVal))分\(Int(self.secondVal))秒").font(.body)

                    HStack {
                        Picker(selection: self.$minuteVal, label: Text("分")) {
                            ForEach(0..<31) { num in
                                Text("\(num)").tag(num).font(.title2)
                            }
                        }
                        .frame(maxWidth: geometry.size.width / 4)
                        .clipped()
                        .padding()

                        Text("分").frame(width: 50, height: 30)
                            .frame(maxWidth: geometry.size.width / 4)
                            .clipped()

                        Picker(selection: self.$secondVal, label: Text("秒")) {
                            ForEach(0..<61) { num in
                                Text("\(num)").tag(num).font(.title2)
                            }
                        }
                        .frame(maxWidth: geometry.size.width / 4)
                        .clipped()
                        .padding()

                        Text("秒").frame(width: 50, height: 30)
                            .frame(maxWidth: geometry.size.width / 4)
                            .clipped()
                    }

                    NavigationLink(
                        destination: TimerView(timerScreenShow: self.$timerScreenShow, timeVal: getSecond(minute: self.minuteVal, second: self.secondVal)),
                        isActive: self.$timerScreenShow,
                        label: {
                            Text("Start")
                        })
                        .padding()
                }
            }
        }
    }

    private func getSecond(minute:Int, second:Int) -> Double {
        return Double(Double(minute) * Double(60) + Double(second))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
