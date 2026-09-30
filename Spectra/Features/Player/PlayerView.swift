
import SwiftUI


struct PlayerView: View {
    
    // StateObject keeps the ViewModel alive while this screen is active.
    // The ViewModel contains the song state, playback state,
    // FFT bands, duration, current time, etc.
    @StateObject private var viewModel: PlayerViewModel
    
    @EnvironmentObject private var coordinator: AppCoordinator

    init(track: Track) {
        _viewModel = StateObject(
            wrappedValue: PlayerViewModel(track: track)
        )
    }
    
    
    // This helper function converts time in seconds
    // into a readable format such as:
    // 65 seconds -> 1:05
    private func formatTime(_ time: Double) -> String {
        
        // If the value is invalid, return 0:00
        guard time.isFinite else {
            return "0:00"
        }
        
        // Convert Double seconds to whole seconds.
        let totalSeconds = Int(time)
        
        // Calculate minutes.
        let minutes = totalSeconds / 60
        
        // Calculate remaining seconds.
        let seconds = totalSeconds % 60
        
        // Example:
        // minutes = 2
        // seconds = 7
        // Output = "2:07"
        return String(
            format: "%d:%02d",
            minutes,
            seconds
        )
    }
    
    
    // body describes what the screen looks like.
    var body: some View {
        
        // VStack arranges everything vertically.
        // spacing: 20 means there is 20-point spacing
        // between the major sections.
        ZStack {
            Color.black
                .ignoresSafeArea()
            Spacer()
            VStack(spacing: 24) {
                Spacer()
                
                // MARK: - Song Icon
                
                // Displays a simple music note icon.
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white)
                
                
                // MARK: - Song Title
                
                // Displays the title of the selected song.
                
                Text(viewModel.track.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white,
                                .purple.opacity(0.8),
                                .blue.opacity(0.5)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 50
                        )
                    )
                    .shadow(
                        radius: 20 + CGFloat(viewModel.beatIntensity) * 25
                    )
                    .frame(width: 90, height: 90)
                    .scaleEffect(
                        1 + CGFloat(viewModel.beatIntensity) * 0.35
                    )
                    .animation(
                        .spring(
                            response: 0.18,
                            dampingFraction: 0.55
                        ),
                        value: viewModel.beatIntensity
                    )
                
                // MARK: - Frequency Visualizer
                
                // HStack arranges the frequency bars horizontally.
                // alignment: .center means every bar grows
                // around the vertical center.
                HStack(
                    alignment: .center,
                    spacing: 5
                ) {
                    
                    // frequencyBands contains your normalized FFT values.
                    //
                    // Example:
                    // [0.1, 0.4, 0.9, 0.3, ...]
                    //
                    // enumerated() gives:
                    // index + value
                    //
                    // We use the index as the unique ID.
                    ForEach(
                        Array(
                            viewModel.frequencyBands.enumerated()
                        ),
                        id: \.offset
                    ) { _, value in
                        
                        // Each frequency band is displayed
                        // as one rounded vertical bar.
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                    LinearGradient(
                                        colors: [
                                            .blue,
                                            .purple
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            .frame(
                                
                                // Width of every spectrum bar.
                                width: 10,
                                
                                // Base height = 12
                                //
                                // value * 65 adds extra height
                                // depending on the frequency energy.
                                //
                                // Example:
                                //
                                // value = 0
                                // height = 12
                                //
                                // value = 0.5
                                // height = 44.5
                                //
                                // value = 1
                                // height = 77
                                height:
                                    12 +
                                CGFloat(value) * 65
                            )
                    }
                }
                
                // Limits the visualizer area
                // so it does not take the whole screen.
                .frame(height: 90)
                
                
                // MARK: - Play / Pause Button
                
                Button {
                    
                    // Calls the ViewModel.
                    //
                    // If currently playing:
                    // -> pause
                    //
                    // If currently paused:
                    // -> play
                    viewModel.togglePlayback()
                    
                } label: {
                    
                    // The icon automatically changes
                    // depending on playback state.
                    Image(
                        systemName:
                            viewModel.isPlaying
                        ? "pause.circle.fill"
                        : "play.circle.fill"
                    )
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
                }
                
                Button("View Audio DNA") {
                    coordinator.showAudioDNA(
                        track: viewModel.track,
                        features: viewModel.audioFeatures
                    )
                }
                .buttonStyle(.borderedProminent)
                
                // MARK: - Progress Section
                
                VStack(spacing: 8) {
                    
                    
                    // Prevent duration from being zero.
                    //
                    // ProgressView needs a valid total value.
                    let safeDuration = max(
                        viewModel.duration,
                        1
                    )
                    
                    // Prevent currentTime from becoming:
                    //
                    // less than 0
                    //
                    // OR
                    //
                    // greater than the duration.
                    //
                    // This prevents SwiftUI warnings.
                    let safeCurrentTime = min(
                        max(
                            viewModel.currentTime,
                            0
                        ),
                        safeDuration
                    )
                    
                    // MARK: Progress Bar
                    
                    // Displays current playback progress.
                    //
                    // Example:
                    //
                    // currentTime = 30
                    // duration = 120
                    //
                    // Progress = 25%
                    ProgressView(
                        value: safeCurrentTime,
                        total: safeDuration
                    )
                    .tint(.purple)
                    
                    // MARK: Time Labels
                    
                    HStack {
                        
                        // Current playback position.
                        //
                        // Example:
                        // 0:34
                        Text(
                            formatTime(
                                viewModel.currentTime
                            )
                        )
                        
                        // Pushes the duration text
                        // to the far right.
                        Spacer()
                        
                        // Total duration of the song.
                        //
                        // Example:
                        // 3:42
                        Text(
                            formatTime(
                                viewModel.duration
                            )
                        )
                    }
                    
                    // Makes the time labels smaller.
                    .font(.caption)
                    
                    // Makes them visually less prominent.
                    .foregroundStyle(.gray)
                }
            }
            // Adds horizontal spacing
            // between the content and screen edges.
            .padding(.horizontal)
        }
    }
}

