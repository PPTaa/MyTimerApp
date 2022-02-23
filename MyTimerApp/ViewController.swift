//
//  ViewController.swift
//  MyTimerApp
//
//  Created by leejungchul on 2022/02/22.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var toggleBtn: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var duration = 60
    
    // timer의 상태
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleBtn()
    }
    
    func configureToggleBtn() {
        self.toggleBtn.setTitle("시작", for: .normal)
        self.toggleBtn.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if self.timer == nil {
            // UI관련 작업은 메인스레드에서 작업해여함
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            // deadline 언제 시작할 지, repeating 몇초마다 작업할 지
            self.timer?.schedule(deadline: .now(), repeating: 1)
            // 1초에 한번씩 핸들러의 클로저가 실행됨
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                UIView.animate(withDuration: 0.5, delay: 0) {
//                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                    self.imageView.transform = CGAffineTransform(translationX: -50, y: 0)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0.5) {
                    self.imageView.transform = CGAffineTransform(translationX: 50, y: 0)
//                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                }
                
                debugPrint(self.currentSeconds)
                if self.currentSeconds <= 0 {
                    // 타이머 종료
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            // 타이머 시작
            self.timer?.resume()
            
        }
    }
    
    func stopTimer() {
        if timerStatus == .pause {
            self.timer?.resume()
        }
        
        self.timerStatus = .end
        self.cancelBtn.isEnabled = false
//        self.setTimerInfoViewVisible(isHidden: true)
        print(self.timerLabel.alpha)
        print(self.progressView.alpha)
        print(self.datePicker.alpha)
        UIView.animate(withDuration: 0.5) {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        }
        
        print(self.timerLabel.alpha)
        print(self.progressView.alpha)
        print(self.datePicker.alpha)
        
        self.toggleBtn.isSelected = false
        
        self.timer?.cancel()
        // 메모리 해제
        self.timer = nil
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
        default:
            break
        }
    }
    
    @IBAction func tapToggleBtn(_ sender: Any) {
        self.duration = Int(self.datePicker.countDownDuration)
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            
            UIView.animate(withDuration: 0.5) {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            }
            self.toggleBtn.isSelected = true
            self.cancelBtn.isEnabled = true
            self.startTimer()
            
        case .start:
            self.timerStatus = .pause
            self.toggleBtn.isSelected = false
            // 일시정지
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggleBtn.isSelected = true
            // 타이머 시작
            self.timer?.resume()
            
        default:
            break
        }
    }
    
}

enum TimerStatus {
    case start
    case pause
    case end
}
