//
//  LaunchScreenView.swift
//  BouncingText
//
//  Created by Larry Burris on 3/15/22.
//
import SwiftUI

struct LaunchScreenView: View
{
    @State var isActive: Bool = false

    var body: some View
    {
        if isActive
        {
            TaskListView()
        }
        else
        {
            ZStack
            {
                Image("sky")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(0.25)
                    .ignoresSafeArea()

                VStack
                {
                    Spacer()

                    Text("Moving Tasks")
                        .font(.custom("Verdana", fixedSize: 40))
                        .fontWeight(.heavy)
                        .padding()

                    BounceAnimationView(text: "Programmed By", startTime: 0.0)
                    BounceAnimationView(text: "Larry Burris", startTime: 1.5)

                    Spacer()

                    BounceAnimationView(text: "Loading Data...", startTime: 3.0)
                }
                .onAppear
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7)
                    {
                        withAnimation
                        {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct BounceAnimationView: View
{
    let characters: Array<String.Element>

    @State var offsetYForBounce: CGFloat = -50
    @State var opacity: CGFloat = 0
    @State var baseTime: Double

    init(text: String, startTime: Double)
    {
        characters = Array(text)
        baseTime = startTime
    }

    var body: some View
    {
        VStack
        {
            HStack(spacing: 0)
            {
                ForEach(0 ..< characters.count, id: \.self)
                {
                    num in

                    Text(String(self.characters[num]))
                        .font(.custom("Verdana", fixedSize: 18))
                        .offset(x: 0.0, y: offsetYForBounce)
                        .opacity(opacity)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1).delay(Double(num) * 0.1), value: offsetYForBounce)
                }
                .onAppear
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.8 + baseTime))
                    {
                        opacity = 1
                        offsetYForBounce = 0
                    }
                }
            }
        }
    }
}

struct Bounce_Previews: PreviewProvider
{
    static var previews: some View
    {
        LaunchScreenView()
    }
}
