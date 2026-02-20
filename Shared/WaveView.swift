//
//  WaveView.swift
//
//  Created by Paul Hudson on 03/06/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import SwiftUI

#if os(iOS)
import AVFoundation
#endif

struct Wave: Shape {
    // allow SwiftUI to animate the wave phase
    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }

    // how high our waves should be
    var strength: Double

    // how frequent our waves should be
    var frequency: Double

    // how much to offset our waves horizontally
    var phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midWidth = width / 2
        let midHeight = height / 2
        let oneOverMidWidth = 1 / midWidth

        // split our total width up based on the frequency
        let wavelength = width / frequency

        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))

        // Use mic input instead of random jump (iOS only)
        #if os(iOS)
        let amplitude = AudioManager.shared.currentAmplitude
        #else
        let amplitude = 1.0
        #endif

        // now count across individual horizontal points one by one
        for x in stride(from: 0, through: width, by: 1) {
            // find our current position relative to the wavelength
            let relativeX = x / wavelength

            // find how far we are from the horizontal center
            let distanceFromMidWidth = x - midWidth

            // bring that into the range of -1 to 1
            let normalDistance = oneOverMidWidth * distanceFromMidWidth

            let parabola = -(normalDistance * normalDistance ) + 1

            // calculate the sine of that position, adding our phase offset
            let sine = sin(relativeX + phase) * amplitude

            // multiply that sine by our strength to determine final offset, then move it down to the middle of our view
            let y = parabola * (strength + strength) * sine + midHeight

            // add a line to here
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

#if os(iOS)
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var audioEngine: AVAudioEngine
    @Published var currentAmplitude: Double = 1.0

    private init() {
        audioEngine = AVAudioEngine()
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let bus = 0
        let inputFormat = inputNode.outputFormat(forBus: bus)

        // Check if the format is valid
        guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
            print("Invalid audio format: \(inputFormat)")
            return
        }

        inputNode.installTap(onBus: bus, bufferSize: 1024, format: inputFormat) { buffer, _ in
            self.processAudioBuffer(buffer: buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start: \(error.localizedDescription)")
        }
    }

    private func processAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)

        // Normalize avgPower to a range of 0 to 1
        let normalizedAmplitude: Float = max(0.0, min(1.0, (avgPower + 50) / 50))

        // Map normalized amplitude to the range 1.0 to 1.5
        let mappedAmplitude = 0.7 + Double(normalizedAmplitude * 0.5)

        DispatchQueue.main.async {
            self.currentAmplitude = mappedAmplitude
        }
    }
}
#endif

struct WaveView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass? //detects Orientation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass? // detects Orientation
    @State private var phase = 0.0

    var body: some View {
        ZStack {
            Wave(strength: (verticalSizeClass == .regular && horizontalSizeClass == .compact) ? 100 : 40, frequency: 30, phase: self.phase)
                .stroke(Color.pinkColor.opacity(0.5), lineWidth: 7)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                self.phase = .pi * 2 
            }
        }
    }
}

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
    }
}
