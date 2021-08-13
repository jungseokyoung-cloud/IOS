//
//  ComposeViewController.swift
//  MemoApp
//
//  Created by jung on 2021/07/06.
//

import UIKit

class ComposeViewController: UIViewController { // new Memo
    
    
    let formatter : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    var editTarget : Memo? // 편집화면 탭시
    
    var editPinTarget : PinMemo?
     
    var originalMemoContent : String? // 편집이전의 메모 내용
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text,
              memo.count > 0 else {
                alert(message: "Write Memo")
                return
            }
        
        
        if let target = editTarget {
            target.content = memo
            target.insertDate = Date()
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        } else if let target = editPinTarget {
            target.content = memo
            target.insertDate = Date()
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        } else{
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
        
        // notification을 전달(앱을 전달하는 모든 객체로 전달한다고 생각) // 라이오처럼 전달!
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    ///키보드에 관련된 옵저버
    var willShowToken : NSObjectProtocol?
    var willHideToken : NSObjectProtocol?
    
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let memo = editTarget {
            navigationItem.title = "Edit Memo"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else if let pinmemo = editPinTarget {
            navigationItem.title = "Edit Memo"
            memoTextView.text = pinmemo.content
            originalMemoContent = pinmemo.content
        }  else {
            navigationItem.title = "New Memo"
            memoTextView.text = ""
        }
        
        memoTextView.delegate = self // 뷰컨트롤러를 텍스트뷰의 델리게이트로 지정
        
        
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            
            guard let strongSelf = self else { return }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = frame.cgRectValue.height
                
                var inset = strongSelf.memoTextView.contentInset
                inset.bottom = height
                strongSelf.memoTextView.contentInset = inset
                
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
            }
        }) // 클로저에서 키보드 높이 만큼 여백을 추가해야함
        
        
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noit) in
            guard let strongSelf = self else { return }
            
            var inset = strongSelf.memoTextView.contentInset
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset = strongSelf.memoTextView.scrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
            
        })//키보드가 사라질때 여백도 지워주어야함
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ios에서 입력포커스를 가진 뷰를 first responder라 부름
        //textview를 first responder로 만들어주면 textview가 선택되고 자동으로 키보드가 등장
        
        memoTextView.becomeFirstResponder() // 끝
        
        
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        memoTextView.resignFirstResponder()
        
        navigationController?.presentationController?.delegate = nil
    }
    // 편집화면이 표시되기 직전에 델리게이트로 설정되었다가 편집화면이 사라지기 직전에 프레센테이션의 델리게이터가 헤제됨

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ComposeViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) { // 메모를 편집할때마다 이 메서드가 호출됨
        if let original = originalMemoContent, let edited = textView.text {
            if #available(iOS 14.0, *){
                isModalInPresentation = original !=  edited //(원래와 편집한내용이 다르면 true 전달)
                // true가 저장된 상태로 시트를 닫으면 시트가 안닫힘
            } else {
                
            }
        }
    }// 텍스트뷰에서 텍스트를 편집할때마다 반복적으로 호출되는 메서드
    
}

extension ComposeViewController : UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        // 편집된 메모가 다르다면 이 메서드가 호출됨
        let alert = UIAlertController(title: "Alert", message: "Save your edits?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Confirm", style: .default) {[weak self] (action) in
            self?.save(action)
        }// 이버튼을 누르면 클로저가 호출
        alert.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] (action) in
            self?.close(action)
        }// 이버튼을 누르면 클로저가 호출

        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}


extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert") // notification 선언
    
    static let memoDidChange = Notification.Name("memoDidChange")
}
// 쓰기 화면에 메모가 하나 저장되면 notification 을 전달 목록화면은 notification 이 전달 되는 시점에 tableview가 업데이트 되도록
// notification은 라디오라고 생각 라디오는 주파수로 구별하고 notification은 이름 으로 전달
