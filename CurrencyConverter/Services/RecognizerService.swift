
import Speech
import AVFoundation

class RecognizerService {
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    var onSpeechRecognitionResult: ((String?) -> Void)?
    
    func requestAuthorizationRecognizer() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized: print("status authorized")
            case .denied: print("status denied")
            case .notDetermined: print("status notDetermined")
            case .restricted: print("status restricted")
            @unknown default: print("status not")
            }
        }
    }
    
    func startRecognition() {
        let recognitionFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recognitionFormat) { [self] buffer, audiTime in
            self.recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
            [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let bestTranscription = result.bestTranscription
                self.onSpeechRecognitionResult?(bestTranscription.formattedString)
                if result.isFinal {
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.recognitionRequest.endAudio()
                    self.recognitionTask = nil
                }
            } else if let error = error {
                print(error.localizedDescription)
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest.endAudio()
                self.recognitionTask = nil
            }
        }
    }
    
    func stopRecognition() {
        audioEngine.stop()
        recognitionRequest.endAudio()
        recognitionTask?.cancel()
    }
}
