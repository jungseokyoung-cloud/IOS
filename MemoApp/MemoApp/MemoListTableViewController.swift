//
//  MemoListTableViewController.swift
//  MemoApp
//
//  Created by jung on 2021/07/05.
//

import UIKit

class MemoListTableViewController: UITableViewController {
    
//    @IBOutlet weak var tableView: UITableView!
    
    var sections = ["Pin Memo" , "Memo"]
        
    let formatter : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    // 시간을 이쁘게 출력하기 위한 클로저!
    
    // 해당 뷰가 호출되기 이전에 실행
    
    
    override func viewWillAppear(_ animated: Bool) { // 즉 해당 페이지가 로드 될때마다 날짜순으로 메모를 정렬하고 데이터를 갱신
        super.viewWillAppear(animated)
        
        DataManager.shared.fetchMemo() // 메모를 날짜순으로 정렬 !
        tableView.reloadData()
    }
    
    var token : NSObjectProtocol?
     
    deinit { // 옵저버 해제
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 세그웨이가 연결된 화면을 생성하고 화면을 전환하기 전에 호출

        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let  vc = segue.destination as? DetailViewViewController { // 세그웨이가 detailviewController로 연결
                                // 새롭게 표시될 화면이 destination
                if indexPath.section == 1{
                    vc.memo = DataManager.shared.memoList[indexPath.row]
                // 디테일 뷰 컨트롤러가 표시할 화면을 지정해줌

                // cell 에는 cell하나하나 를 나타냄 indextPath로 몇번째 cell인지 알 수 있음
                } else if indexPath.section == 0 {
                    vc.pinMemo = DataManager.shared.pinMemoList[indexPath.row]
                }
            }
            
        }// indexPath 프로퍼티를 통해 몇번째 메모인지 알 수 있음
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.reloadSection()
        
        tableView.delegate = self
        tableView.dataSource = self
        
       token = NotificationCenter.default.addObserver(forName: ComposeViewController.newMemoDidInsert, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.tableView.reloadData()
        }
        
        // 클로저가 queue에 지정한 위치에서 실행됨
        
        // 옵저버 추가는 한번만 구현하면되기 때문에 viewDidLoad에 구현!
        //addObserver는 리턴시 옵저버를 사용할때 사용하는 객체를 리턴함 이 객채를 토큰이라 부름

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("Value: \(DataManager.shared.pinMemoList[indexPath.row])")

        } else if indexPath.section == 1 {
            print("Value: \(DataManager.shared.memoList[indexPath.row])")

        } else {
            return

        }

    }

   
    
   
    // MARK: - Table view data source

    override func tableView(_ tableView : UITableView, numberOfRowsInSection section : Int) -> Int {
        if section == 0 {
            return DataManager.shared.pinMemoList.count
        } else if section == 1 {
            return DataManager.shared.memoList.count
        } else {
            return 0
        }
    }

    
    // 어떤 디자인으로 어떻게 표시해야 되는지 알려줌!
    // 한개의 셀마다 한번씩 출력됨
    // indexPath라는 매개변수 가 셀의 특정위치를 지정하면서 알수 있음.
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //테이블뷰에 추가되어있는 프로토타입 셀 중에 "cell" 이라는 identify를 가진 프로토타입을 가져온다
        
        //cell에 표시할 데이터를 가져옴
        //subtitle 속성의 셀은 2개의 속성을 가지고 있다. 위의 속성은 textLabel 로 아래의 속성은 detailTextLabel로 접근가능
        if(indexPath.section == 0){
            let target = DataManager.shared.pinMemoList[indexPath.row] // row속성으로 테이블뷰에서 몇번째 셀인지 확인가능.
            cell.textLabel?.text = target.content
            cell.detailTextLabel?.text = formatter.string(for: target.insertDate)
        } else if indexPath.section == 1 {
            let target = DataManager.shared.memoList[indexPath.row] // row속성으로 테이블뷰에서 몇번째 셀인지 확인가능.
            cell.textLabel?.text = target.content
            cell.detailTextLabel?.text = formatter.string(for: target.insertDate)
        } else {
            return UITableViewCell()
        }
        
//        if #available(iOS 11.0, *){ // 11보다 버전이 낮다면
//            cell.detailTextLabel?.textColor = UIColor(named: "MyLabelColor")
//        } else {
//            cell.detailTextLabel?.textColor = UIColor.lightGray
//        }

        return cell
    }
// 위 2개의 tableView 메서드는 tableView를 구현하기 위한 필수 메서드
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    } // 특정 행의 셀을 수정 가능한지 묻는 함수

//
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pin = UIContextualAction(style: .normal, title: "pin"){ (UIContextualAction, UIView, success:@escaping (Bool) -> Void) in
            success(true)
            if(indexPath.section == 1){
                let target = DataManager.shared.memoList[indexPath.row]
                
                DataManager.shared.addPinMemo(target)
                
                DataManager.shared.deleteMemo(target)
                DataManager.shared.memoList.remove(at: indexPath.row)
                DataManager.shared.fetchMemo()
                self.tableView.reloadData()
//                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if indexPath.section == 0 {
                let target = DataManager.shared.pinMemoList[indexPath.row]
                
                DataManager.shared.removePin(target)
                
                DataManager.shared.deletePinMemo(target)
                DataManager.shared.pinMemoList.remove(at: indexPath.row)
                DataManager.shared.fetchMemo()
                self.tableView.reloadData()
            }
            
            // 이제 pin기능 구현 !
            
        }
        pin.backgroundColor = .systemYellow
        if(indexPath.section == 0) {
            pin.image = UIImage(systemName: "pin.slash")
        } else {
            pin.image = UIImage(systemName: "pin")
        }
        
                
        return UISwipeActionsConfiguration(actions:[pin])
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                // 오른쪽에 만들기

        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            if(indexPath.section == 0){
                let target = DataManager.shared.pinMemoList[indexPath.row]
                
                DataManager.shared.deletePinMemo(target)
                DataManager.shared.pinMemoList.remove(at: indexPath.row)
                
//                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if indexPath.section == 1 {
                
                let target = DataManager.shared.memoList[indexPath.row]

                DataManager.shared.deleteMemo(target)
                DataManager.shared.memoList.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            success(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let shared = UIContextualAction(style: .normal, title: "shared") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            let target = DataManager.shared.memoList[indexPath.row].content
            guard let memo = target else {
                return
            }

            let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)

//            if let pc = vc.popoverPresentationController {
//                pc.barButtonItem = sender
//            }
            //이속성을 통애 아이패드에서 popover를 추가하는 뷰를 지정

            self.present(vc, animated: true, completion: nil)
            //UIActivityController를 화면에 표시
            //이 코드가 공유기능임
            success(true)
        }
        shared.backgroundColor = .systemBlue
        shared.image = UIImage(systemName: "square.and.arrow.up")

        return UISwipeActionsConfiguration(actions:[delete, shared])
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}

extension MemoListTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return sections[section]
    }
}
