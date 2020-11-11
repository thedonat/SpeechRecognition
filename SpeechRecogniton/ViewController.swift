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
    
    @IBOutlet weak var detectedTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    
    let audioEngine = AVAudioEngine() //responsible for receiving the audio signals from the microphone
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "tr-TR"))
    var request = SFSpeechAudioBufferRecognitionRequest() // allocates real-time speech and controls buffering
    var recognitionTask: SFSpeechRecognitionTask? //to manage, cancel, or stop the task.
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        self.requestSpeechAuthorization()
        startButton.layer.cornerRadius = 40
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        recordAndRecognizeSpeech()
        
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode //audio engine uses what are called nodes to process bits of audio
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
        
        //make sure the recognizer is available for the device and for the locale
        guard let myRecognizer = SFSpeechRecognizer() else { return }
        
        if !myRecognizer.isAvailable {
            return
        }
        
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = true
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            
            if error != nil {
                self.audioEngine.stop()
                node.removeTap(onBus: 0)
                self.recognitionTask = nil
                
            } else {
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    self.detectedTextView.text = bestString
                    
                    //identify a specific word
                    var lastString: String = ""
                    for segment in result.bestTranscription.segments {
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = bestString.substring(from: indexTo)
                    }
                    self.checkForColorsSaid(resultString: lastString)
                }
            }
        })
    }
    
    func checkForColorsSaid(resultString: String) {
        
        switch resultString {
            
        case "kırmızı":
            self.view.backgroundColor = .red
        case "mavi":
            self.view.backgroundColor = .blue
        case "yeşil":
            self.view.backgroundColor = .green
        case "sarı":
            self.view.backgroundColor = .yellow
        case "mor":
            self.view.backgroundColor = .purple
        case "turuncu":
            self.view.backgroundColor = .orange
        default: break
        }
    }
    
    func requestSpeechAuthorization() {
        
        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
            OperationQueue.main.addOperation {
                
                guard let self = self else {return}
                
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextView.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextView.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isHidden = false
                    self.detectedTextView.text = "Speech recognition not yet authorized"
                @unknown default:
                    fatalError()
                }
            }
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        detectedTextView.endEditing(true)
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
    
}
