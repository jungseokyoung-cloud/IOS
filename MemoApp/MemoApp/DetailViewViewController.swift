//
//  DetailViewViewController.swift
//  MemoApp
//
//  Created by jung on 2021/07/08.
//

import UIKit

class DetailViewViewController: UIViewController {
    
    @IBOutlet weak var memoTableView: UITableView!
    
    var memo : Memo? // 이전화면에서 전달한 메모를 저장할 속성
    // viewcontroller를 초기화할 당시에는 값이 없기에 옵셔널
    
    var pinMemo : PinMemo?
    
    let formatter : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    
    @IBAction func share(_ sender: UIBarButtonItem) { ///// pin memo 도 공유 기능 추가
        //IOS에서 기본적으로 제공하는 공유하는 기능은 uiactivityviewcontroller로 구현
        
        if let memo = memo?.content {
            let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
            
            if let pc = vc.popoverPresentationController {
                pc.barButtonItem = sender
            }
            //이속성을 통애 아이패드에서 popover를 추가하는 뷰를 지정
            
            present(vc, animated: true, completion: nil)
            //UIActivityController를 화면에 표시
            //이 코드가 공유기능임
        } else if let pinMemo = pinMemo?.content {
            let vc = UIActivityViewController(activityItems: [pinMemo], applicationActivities: nil)
            
            if let pc = vc.popoverPresentationController {
                pc.barButtonItem = sender
            }
            //이속성을 통애 아이패드에서 popover를 추가하는 뷰를 지정
            
            present(vc, animated: true, completion: nil)
            //UIActivityController를 화면에 표시
            //이 코드가 공유기능임
        }
       
    }
    
    
    @IBAction func deleteMemo(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Delete Memo?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Delete", style: .destructive){ [weak self]  (action) in
            DataManager.shared.deleteMemo(self?.memo)
            //--> 메모가 삭제된 다음 이전화면으로 돌아가야함.
            // 현재 화면을 팝해야함 --> 네비게이션 컨트롤러에 접근하고 현재화면 pop
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil) // 어차피 클릭하면 경고창이 닫힘
        
        alert.addAction(cancleAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.children.first as? ComposeViewController {
            
            if let memo = memo {
                vc.editTarget = memo //이렇게 하면 네이게이션 컨트롤러가 관리하는 첫번째 뷰컨트롤러(composeviewcontroller)로 메모가 전달됨
            } else if let pinMemo = pinMemo {
                vc.editPinTarget = pinMemo
            }
        }
    }
    
    var token : NSObjectProtocol?
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            self?.memoTableView.reloadData()
        })

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewViewController :  UITableViewDataSource {
    func tableView(_ tableView : UITableView, numberOfRowsInSection section : Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView : UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = UITableViewCell()
        if let memo = memo  {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "deteCell", for : indexPath)
                
                cell.textLabel?.text = formatter.string(for: memo.insertDate)
                
//                return cell
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for : indexPath)
                
                cell.textLabel?.text = memo.content
                
//                return cell
          
            default :
                fatalError()
            }
        } else if let pinMemo = pinMemo {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "deteCell", for : indexPath)
                
                cell.textLabel?.text = formatter.string(for: pinMemo.insertDate)
                
//                return cell
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for : indexPath)
                
                cell.textLabel?.text = pinMemo.content
                
//                return cell
          
            default :
                fatalError()
            }
        }
        return cell
    }
}
