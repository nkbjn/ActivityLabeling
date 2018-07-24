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
    
    let activities = UserDefaults.standard.array(forKey: Config.activities)!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedItems = [Int: Bool]()

    let api = APIManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(UINib(nibName: "LabelingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeStatus()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // 画面の向きが変わったらアイコンの大きさを更新する
        collectionView.reloadData()
    }
    
    /// 行動が選択されているかどうかを判定する
    ///
    /// - Returns: 行動が一つでも選択されているかどうか
    func selected() -> Bool {
        if selectedItems.isEmpty {
            return false
        }
        return true
    }
    
    
    /// 行動が選択されているかどうかを確認して、ステータスを変更する
    func changeStatus() {
        if selected() {
            // 行動が選択されていればステータスをノーマルに変える
            navigationController?.navigationBar.barTintColor = .flatBlack
            title = ""
        } else {
            // 行動が選択されていなければステータスを未選択に変える
            navigationController?.navigationBar.barTintColor = .flatRed
            title = "Unselected"
        }
    }
    
    
    /// 終了ボタンを押した時の処理
    @IBAction func exit(_ sender: Any) {
        
        guard !selected() else {
            // 行動を選択している状態で終了しようとした場合
            let alert = UIAlertController(title: "Error",
                                          message: "Please finish all activities.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
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
        present(alert, animated: true)
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = view.frame.height
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
        return activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LabelingCollectionViewCell
    
        // Configure the cell
        let activity = activities[indexPath.row] as! String
        cell.imageView.image = UIImage(named: activity)?.withRenderingMode(.alwaysTemplate)
        cell.textLabel.text = activity
        
        if let _ = selectedItems[indexPath.row] {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.isSelected = true
            cell.iconView.backgroundColor = .flatSkyBlue
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            cell.isSelected = false
            cell.iconView.backgroundColor = .flatBlack
        }
    
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = activities[indexPath.row] as! String
        let status = cell.isSelected
        
        let massage = "Would you like to start \(activity)?"
        let alert = UIAlertController(title: "Start Activity", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { action in
            self.api.write(activity: activity, status: status, handler: { error in
                
                guard (error == nil) else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.deselectItem(at: indexPath, animated: true)
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                self.selectedItems[indexPath.row] = true
                cell.iconView.backgroundColor = .flatSkyBlue
                
                self.changeStatus()
                
                
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelingCollectionViewCell
        let activity = activities[indexPath.row] as! String
        let status = cell.isSelected
        
        let massage = "Would you like to finish \(activity)?"
        let alert = UIAlertController(title: "Finish Activity", message: massage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Finish", style: .default, handler: { action in
            self.api.write(activity: activity, status: status, handler: { error in
                
                guard (error == nil) else {
                    // 通信失敗したら選択状態を元に戻す
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                self.selectedItems.removeValue(forKey: indexPath.row)
                cell.iconView.backgroundColor = .flatBlack
                
                self.changeStatus()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // キャンセル時には選択状態を元に戻す
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }))
        present(alert, animated: true)
    }

}
