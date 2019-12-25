//
//  LabelingViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/15.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import APIKit

private let reuseIdentifier = "Cell"

class LabelingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let api = APIManager.shared
    let activities = UserDefaults.standard.array(forKey: Config.activities)!
    var selectedItems = [Int: Bool]()
    
//    @IBAction func stressLevel1ButtonTapped(_ sender: Any) {
//        print("hoge")
//    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    /// 行動が選択されているかどうかを判定する
    ///
    /// - Returns: 行動が一つでも選択されているかどうか
    func selected() -> Bool {
        if self.selectedItems.isEmpty {
            return false
        }
        return true
    }
    
    /// 行動が選択されているかどうかを確認して、ステータスを変更する
    func changeStatus() {
        if self.selected() {
            // 行動が選択されていればステータスをノーマルに変える
            self.navigationController?.navigationBar.barTintColor = .flatBlack()
            self.title = "Selected"
        } else {
            // 行動が選択されていなければステータスを未選択に変える
            self.navigationController?.navigationBar.barTintColor = .flatRed()
            self.title = "Unselected"
        }
    }
    
    /// 終了ボタンを押した時の処理
    @IBAction func exit(_ sender: Any) {
        
        guard !self.selected() else {
            // 行動を選択している状態で終了しようとした場合
            let alert = UIAlertController(title: "Error",
                                          message: "Please finish all activities.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // 誤って終了してしまうのを防ぐためにアラートを表示
        let alert = UIAlertController(title: "Finish Labeling",
                                      message: "Would you like to finish labeling?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Finish",
                                      style: .default,
                                      handler: { action in
                                        self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UINib(nibName: "LabelingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.allowsMultipleSelection = true
        
        self.changeStatus()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // 画面の向きが変わったらアイコンの大きさを更新する
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = self.view.frame.width
        let height: CGFloat = self.view.frame.height
        var cellSize: CGFloat = 0
        if width < height {
            cellSize = width / 5
        } else {
            cellSize = height / 5
        }
        return CGSize(width: cellSize, height: cellSize)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LabelingCollectionViewCell
    
        // Configure the cell
        let activity = self.activities[indexPath.row] as! String
        cell.imageView.image = UIImage(named: activity)?.withRenderingMode(.alwaysTemplate)
        cell.textLabel.text = activity
        
        if selectedItems[indexPath.row] != nil {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.isSelected = true
            cell.iconView.backgroundColor = .flatSkyBlue()
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            cell.isSelected = false
            cell.iconView.backgroundColor = .flatBlack()
        }
    
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = activities[indexPath.row] as! String
        let status = cell.isSelected
        let time = Date()
        let isStress = self.isStress(activity: activity)
        let massage = self.selectStartMessage(activity: activity, isStress: isStress)
        let alert = isStress ? UIAlertController(title: "Select Stress Level", message: massage, preferredStyle: .alert) : UIAlertController(title: "Start Activity", message: massage, preferredStyle: .alert)
        let title = isStress ? "Select" : "Start"
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { action in
            self.api.write(time: time, activity: activity, status: status, handler: { error in
                
                guard (error == nil) else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.deselectItem(at: indexPath, animated: true)
                    
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if(!isStress){
                    self.selectedItems[indexPath.row] = true
                    cell.iconView.backgroundColor = .flatSkyBlue()
                
                    self.changeStatus()
                }else{
                    collectionView.deselectItem(at: indexPath, animated: true)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = self.activities[indexPath.row] as! String
        let status = cell.isSelected
        let time = Date()
        
        let massage = "Would you like to finish \(activity)?"
        
        let alert = UIAlertController(title: "Finish Activity", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Finish", style: .default, handler: { action in
            self.api.write(time: time, activity: activity, status: status, handler: { error in
                
                guard (error == nil) else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                    
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                self.selectedItems.removeValue(forKey: indexPath.row)
                cell.iconView.backgroundColor = .flatBlack()
                
                self.changeStatus()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }))
        self.present(alert, animated: true)
    }

    func isStress( activity: String) -> Bool {
        return (activity == "StressLevel1" || activity == "StressLevel2" || activity == "StressLevel3" || activity == "StressLevel4" || activity == "StressLevel5")
    }

    
    func selectStartMessage( activity: String, isStress: Bool) -> String {
        return isStress ? "Would you like to select \(activity)?" : "Would you like to start \(activity)?"
    }
}
