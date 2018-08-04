//
//  ViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/07/22.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        view.addGestureRecognizer(longGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //コマンド検出 ダブルタップホールドに変える？
    @objc func longTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            showInstantAlert()
        }
    }
    
    func showInstantAlert() {
        // アラート作成
        let alert = UIAlertController(title: "録音画面に移ります", message: "", preferredStyle: .alert)
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //print("遷移の処理")
            // タブバーのインスタンス(ストーリーボードが変わった時点で一階死んでいる？)を取得
            if let tabvc = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController  {
                //左から２番目のタブアイコンを選択状態にする(0が一番左)
                tabvc.selectedIndex = 1
            }
            
            // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let dstView = storyboard.instantiateViewController(withIdentifier: "RecordViewController")
            
            self.tabBarController?.navigationController?.present(dstView, animated: true, completion: nil)
            
            //let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            //nextViewController.tabBarController?.selectedIndex = 1 //Feedに書けばここまででよい //外からだとここがきかない
            //self.present(nextViewController, animated:true, completion:nil)
            //
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func getNowMonthDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        let now = Date()
        return formatter.string(from: now)
    }
    
    func getNowDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd_HHmmss"
        let now = Date()
        return formatter.string(from: now)
    }
}

