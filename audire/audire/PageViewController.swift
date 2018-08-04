//
//  PageViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/08/11.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    let sboard: UIStoryboard? = UIStoryboard(name:"Main", bundle:nil)
    var pageViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //自分自身を指定
        dataSource = self
        
        // Do any additional setup after loading the view.
        let recordViewController: RecordViewController = sboard!.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
        
        let feedViewController: FeedViewController = sboard!.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        
        //全ページを配列に格納
        pageViewControllers = [recordViewController,feedViewController]
        //UIPageViewControllerに表示対象を設定
        setViewControllers([pageViewControllers[1]], direction: .forward, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController:
        UIPageViewController, viewControllerBefore viewController:UIViewController) -> UIViewController? {
        //右にスワイプした場合に表示したいviewControllerを返す
        //ページを戻す
        //今表示しているページは何ページ目か取得する
        let index = pageViewControllers.index(of: viewController)
        if index == 0 {
            //1ページ目の場合は何もしない
            return nil
        } else {
            //1ページ目の意外場合は1ページ前に戻す
            return pageViewControllers[index!-1]
        }
    }
    
    func pageViewController(_ pageViewController:
        UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //左にスワイプした場合に表示したいviewControllerを返す
        //ページを進める
        //今表示しているページは何ページ目か取得する
        let index = pageViewControllers.index(of: viewController)
        if index == pageViewControllers.count-1 {
            //最終ページの場合は何もしない
            return nil
        } else {
            //最終ページの意外場合は1ページ進める
            return pageViewControllers[index!+1]
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
