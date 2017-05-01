//
//  HistoryVC.swift
//  IOSLab5
//
//  Created by Thitiwat on 5/1/2560 BE.
//  Copyright © 2560 Thitiwat. All rights reserved.
//

import UIKit
import Firebase

class HistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var ref: FIRDatabaseReference!
    let userId = UserDefaults.standard.object(forKey: "userid") as! String
    var historylist = [History]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historylist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        let history = historylist[indexPath.row]
        cell.timeLabel.text = history.time
        cell.ipHis.text = history.ip
        
        print(cell.timeLabel.text!)
        print(cell.ipHis.text!)
        return cell
    
    }
    
    func loadData(){
        ref = FIRDatabase.database().reference().child("History").child(userId)
        ref.observe(.value, with: { snapshot in
            if let hisDic = snapshot.value as? [String : AnyObject]{
                for(_,hisElement) in hisDic{
                    let history = History()
                    history.ip = hisElement["IP"] as? String
                    history.time = hisElement["Time"] as? String
                    self.historylist.append(history)
                }
                self.historylist.sort(by: { $0.time! > $1.time! })
            }
            print(self.historylist.count)
            self.tableView.reloadData()
        })
        
        
    }
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let mainStory: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        
        let desController = mainStory.instantiateViewController(withIdentifier:"DetailVC") as! DetailVC
        
        self.present(desController, animated: true, completion: nil)
    }
    

}
