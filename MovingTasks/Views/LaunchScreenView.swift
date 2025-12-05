//
//  LaunchScreenView.swift
//  BouncingText
//
//  Created by Larry Burris on 3/15/22.
//
import SwiftUI

/// A splash screen view that displays an animated introduction before presenting the main task list.
///
/// `LaunchScreenView` serves as the app's entry point, providing a visually engaging introduction
/// with animated text elements and a background image. The view automatically transitions to the
/// main `TaskListView` after a predetermined delay.
///
/// ## Visual Elements
///
/// The launch screen consists of:
/// - A semi-transparent background image ("sky") that fills the entire screen
/// - A title ("Moving Tasks") displayed in a large, heavy Verdana font
/// - Three animated text lines that bounce in sequentially:
///   - "Programmed By" (appears at 0.0 seconds)
///   - "Larry Burris" (appears at 1.5 seconds)
///   - "Loading Data..." (appears at 3.0 seconds)
///
/// ## Animation Behavior
///
/// Each text line is rendered using `BounceAnimationView`, which animates individual characters
/// with a spring animation effect. Characters appear sequentially from left to right, creating
/// a typewriter-like bouncing effect.
///
/// ## Transition Logic
///
/// After 7 seconds, the view automatically transitions to `TaskListView` with a smooth animation.
/// The transition is managed through the `isActive` state property, which triggers a conditional
/// view replacement when set to `true`.
///
/// ## Usage Example
///
/// ```swift
/// @main
/// struct MovingTasksApp: App {
///     var body: some Scene {
///         WindowGroup {
///             LaunchScreenView()
///         }
///     }
/// }
/// ```
///
/// - Note: The 7-second delay is hardcoded and consists of the animation sequence timing
///   plus time for the user to see the final "Loading Data..." message.
///
struct LaunchScreenView: View
{
    // MARK: - Properties
    
    /// Controls whether to display the launch screen or transition to the main task list.
    ///
    /// When `false`, the launch screen with animations is displayed.
    /// When `true`, the app transitions to `TaskListView`.
    /// This property is automatically set to `true` after a 7-second delay.
    @State var isActive: Bool = false

    // MARK: - Body
    
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

/// A view that animates individual characters of a text string with a bouncing effect.
///
/// `BounceAnimationView` creates an engaging character-by-character animation where each letter
/// bounces into place sequentially from left to right. The animation uses a spring effect for
/// a natural, playful appearance.
///
/// ## Animation Details
///
/// Each character in the provided text:
/// - Starts 50 points above its final position
/// - Begins with zero opacity
/// - Animates into place using a spring animation with specific response and damping values
/// - Has a staggered delay of 0.1 seconds between characters
///
/// The entire animation sequence has a configurable start delay, allowing multiple
/// `BounceAnimationView` instances to be choreographed in sequence.
///
/// ## Parameters
///
/// - `text`: The string to animate. Each character will be animated individually.
/// - `startTime`: The delay (in seconds) before the animation begins. This allows for
///   sequential animations across multiple views.
///
/// ## Usage Example
///
/// ```swift
/// VStack {
///     BounceAnimationView(text: "Hello", startTime: 0.0)
///     BounceAnimationView(text: "World", startTime: 1.5)
/// }
/// ```
///
/// - Note: The animation uses `.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1)`
///   for a bouncy, energetic effect.
///
struct BounceAnimationView: View
{
    // MARK: - Properties
    
    /// An array of individual characters from the input text.
    ///
    /// Breaking the text into individual characters allows each one to be animated
    /// independently with staggered timing.
    let characters: Array<String.Element>

    /// The vertical offset for the bounce animation.
    ///
    /// Characters start at -50 (above their final position) and animate to 0
    /// (their final position).
    @State var offsetYForBounce: CGFloat = -50
    
    /// The opacity of the characters.
    ///
    /// Characters start invisible (0) and fade in to full opacity (1) as they
    /// animate into position.
    @State var opacity: CGFloat = 0
    
    /// The base delay time before the animation sequence begins.
    ///
    /// This value is combined with the character index delay to create the
    /// staggered animation effect.
    @State var baseTime: Double

    // MARK: - Initialization
    
    /// Creates a new bounce animation view with the specified text and start time.
    ///
    /// - Parameters:
    ///   - text: The text string whose characters will be animated
    ///   - startTime: The delay in seconds before the animation begins
    // MARK: - Initialization
    
    /// Creates a new bounce animation view with the specified text and start time.
    ///
    /// - Parameters:
    ///   - text: The text string whose characters will be animated
    ///   - startTime: The delay in seconds before the animation begins
    init(text: String, startTime: Double)
    {
        characters = Array(text)
        baseTime = startTime
    }

    // MARK: - Body
    
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
