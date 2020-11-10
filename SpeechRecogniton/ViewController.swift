//
//  ViewController.swift
//  SpeechRecogniton
//
//  Created by Burak Donat on 9.11.2020.
//  Copyright © 2020 Burak Donat. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    
    let audioEngine = AVAudioEngine() //perform mic to reviece audio
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "tr-TR"))
    let request = SFSpeechAudioBufferRecognitionRequest() // allocates real-time speech and controls buffering
    var recognitionTask: SFSpeechRecognitionTask? //to manage, cancel, or stop the task.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        recordAndRecognizeSpeech()
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch  {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else { return }
        
        if !myRecognizer.isAvailable {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
            }
                print(lastString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
}

extension ViewController: SFSpeechRecognizerDelegate {
    
}
