//
//  ContentView.swift
//  TimerProto
//
//  Created by 浜田諒 on 2021/03/18.
//

import SwiftUI
import AudioToolbox

struct TimerView: View {
    @State var diff:Double = Double(0)
    @Binding var timerScreenShow:Bool
    @Binding var timeVal:Double
    
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
                        Text("\(Int(self.timeVal) + 1)").font(.system(size: 40))
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
}

struct ContentView: View {
    @State var timeVal:Double = 1
    @State var timerScreenShow:Bool = false

    var body: some View {
        NavigationView{
            VStack {
                Text("Timer \(Int(self.timeVal)) seconds").font(.body)
                Picker(selection: self.$timeVal, label: Text("")) {
                    Text("1").tag(Double(1)).font(.title2)
                    Text("5").tag(Double(5)).font(.title2)
                    Text("10").tag(Double(10)).font(.title2)
                    Text("30").tag(Double(30)).font(.title2)
                    Text("60").tag(Double(60)).font(.title2)
                }
                NavigationLink(
                    destination: TimerView(timerScreenShow: self.$timerScreenShow, timeVal: self.$timeVal),
                    isActive: self.$timerScreenShow,
                    label: {
                        Text("Start")
                    })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
