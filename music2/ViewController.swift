//
//  ViewController.swift
//  music2
//
//  Created by 김천중 on 2022/05/10.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    var player: AVAudioPlayer!
    var timer: Timer!
    
    //MARK: IBOutlets
    @IBOutlet var playbutton:UIButton!
    @IBOutlet var timelabel:UILabel!
    @IBOutlet var playerslider: UISlider!
    
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeplayer()
    }

    //MARK: player setting
    func initializeplayer() {
        
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다.")
            return
        }
        
        do {
            try self.player=AVAudioPlayer(data: soundAsset.data)
            self.player.delegate=self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
        
        self.playerslider.value=Float(self.player.currentTime)
        self.playerslider.minimumValue=0
        self.playerslider.maximumValue=Float(self.player.duration)
        
    }

    func timeupdate_label(time: TimeInterval) {
        let minute: Int = Int(time/60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1)*100)
        
        let timeText: String = String(format:"%02ld:%02ld:%02ld", minute, second, milisecond)
        
        self.timelabel.text = timeText
    }
    
    func makeandfiretimer() {
        
        self.timer=Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
            
            if self.playerslider.isTracking { return }
            
            self.timeupdate_label(time: self.player.currentTime)
            self.playerslider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    func invalidatetimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    
    @IBAction func playpause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
            self.makeandfiretimer()
        } else {
            self.player?.pause()
            self.invalidatetimer()
        }
    }
    
    @IBAction func sliderchage(_ sender: UISlider) {
        self.timeupdate_label(time: TimeInterval(sender.value))
        if sender.isTracking {return}
        self.player.currentTime = TimeInterval(sender.value)
    }
    
    //MARK: AVAudioPlayerDelegate
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)

        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playbutton.isSelected=false
        self.playerslider.value=0
        self.timeupdate_label(time: 0)
        self.invalidatetimer()
    }
}

