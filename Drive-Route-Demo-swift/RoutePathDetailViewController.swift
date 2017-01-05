//
//  RoutePathDetailViewController.swift
//  Drive-Route-Demo
//
//  Created by eidan on 16/12/22.
//  Copyright © 2016年 autonavi. All rights reserved.
//

import UIKit

class RoutePathDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    //xib views
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var timeInfoLabel: UILabel!
    
    @IBOutlet weak var taxiCostInfoLabel: UILabel!
    
    let RoutePathDetailTableViewCellIdentifier = "RoutePathDetailTableViewCellIdentifier"
    
    var route: AMapRoute!;
    
    var path: AMapPath!;
    
    var routeDetailDataArray: NSMutableArray!  //路径步骤数组
    
    let drivingImageDic = [  //根据AMapStep.action获得对应的图片名字
        "开始": "start",
        "结束": "end",
        "右转": "right",
        "左转": "left",
        "直行": "straight",
        "向右前方行驶": "rightFront",
        "向左前方行驶": "leftFront",
        "向左后方行驶": "leftRear",
        "向右后方行驶": "rightRear",
        "左转调头": "leftRear",
        "靠左": "leftFront",
        "靠右": "rightFront",
        "进入环岛": "straight",
        "离开环岛": "straight",
        "减速行驶": "dottedStraight",
        "插入直行": "straight",
        "": "straight"]
    
    func setUpViews() {
        
        let startStep = AMapStep()
        startStep.action = "开始"  //导航主要动作，用来标示图标
        startStep.instruction = "开始"  //行走指示
        
        let endStep = AMapStep()
        endStep.action = "结束"
        endStep.instruction = "抵达"
        
        self.routeDetailDataArray = []
        
        self.routeDetailDataArray.add(startStep)
        self.routeDetailDataArray.addObjects(from: self.path.steps)
        self.routeDetailDataArray.add(endStep)
        
        self.tableView.tableHeaderView = self.headerView
        self.tableView.register(UINib(nibName: "RoutePathDetailTableViewCell", bundle: nil), forCellReuseIdentifier: RoutePathDetailTableViewCellIdentifier)
        self.tableView.rowHeight = 54
        
        let hours = self.path!.duration / 3600
        let minutes = Int(self.path!.duration / 60) % 60
        self.timeInfoLabel.text = "\(UInt(hours))小时\(UInt(minutes))分钟（\(UInt(self.path!.distance) / 1000)公里）"
        self.taxiCostInfoLabel.text = String(format: "打车约%.0f元", self.route.taxiCost)
        
    }
    
    // MARK: - UITableView Delegate and DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routeDetailDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RoutePathDetailTableViewCell = (tableView.dequeueReusableCell(withIdentifier: RoutePathDetailTableViewCellIdentifier, for: indexPath) as! RoutePathDetailTableViewCell)
        
        let step = self.routeDetailDataArray.object(at: indexPath.row) as! AMapStep
        cell.infoLabel.text = step.instruction
        cell.actionImageView.image = UIImage(named: (self.drivingImageDic[step.action])!)
        cell.topVerticalLine.isHidden = indexPath.row == 0
        cell.bottomVerticalLine.isHidden = indexPath.row == self.routeDetailDataArray.count - 1

        return cell
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpViews()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - xib click
    
    @IBAction func goBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
