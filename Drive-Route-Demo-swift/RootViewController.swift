//
//  RootViewController.swift
//  Drive-Route-Demo
//
//  Created by eidan on 16/12/21.
//  Copyright © 2016年 autonavi. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    let RoutePlanningPaddingEdge = CGFloat(20)
    let RoutePlanningViewControllerStartTitle = "起点"
    let RoutePlanningViewControllerDestinationTitle = "终点"
    
    var mapView: MAMapView!         //地图
    var search: AMapSearchAPI!      // 地图内的搜索API类
    var route: AMapRoute!           //路径规划信息
    var naviRoute: MANaviRoute?     //用于显示当前路线方案.
    
    var startAnnotation: MAPointAnnotation!
    var destinationAnnotation: MAPointAnnotation!
    
    var startCoordinate: CLLocationCoordinate2D! //起始点经纬度
    var destinationCoordinate: CLLocationCoordinate2D! //终点经纬度
    
    var totalRouteNums: NSInteger!  //总共规划的线路的条数
    var currentRouteIndex: NSInteger!   //当前显示线路的索引值，从0开始
    
    //xibViews
    @IBOutlet weak var showTrafficSwitch: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var switchRouteBtn: UIButton!
    @IBOutlet weak var routeDetailBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMapViewAndSearch()
        
        self.setUpData()
        
        self.resetSearchResultAndXibViewsToDefault()
        
        self.addDefaultAnnotations()
        
        self.searchRoutePlanningDrive()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //初始化地图,和搜索API
    func initMapViewAndSearch() {
        self.mapView = MAMapView(frame: CGRect(x: CGFloat(0), y: CGFloat(64), width: CGFloat(self.view.bounds.size.width), height: CGFloat(self.view.bounds.size.height - 45 - 64)))
        self.mapView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        self.search = AMapSearchAPI()
        self.search.delegate = self
    }
    
    //初始化坐标数据
    func setUpData() {
        self.startCoordinate = CLLocationCoordinate2DMake(39.910267, 116.370888)
        self.destinationCoordinate = CLLocationCoordinate2DMake(39.989872, 116.481956)
    }
    
    //初始化或者规划失败后，设置view和数据为默认值
    func resetSearchResultAndXibViewsToDefault() {
        self.totalRouteNums = 0
        self.currentRouteIndex = 0
        self.switchRouteBtn.isEnabled = false
        self.routeDetailBtn.isEnabled = false
        self.showTrafficSwitch.isEnabled = false
        self.infoLabel.text = ""
        self.naviRoute?.removeFromMapView()
        
    }
    //在地图上添加起始和终点的标注点
    func addDefaultAnnotations() {
        let startAnnotation = MAPointAnnotation()
        startAnnotation.coordinate = self.startCoordinate
        startAnnotation.title = RoutePlanningViewControllerStartTitle
        startAnnotation.subtitle = "{\(self.startCoordinate.latitude), \(self.startCoordinate.longitude)}"
        self.startAnnotation = startAnnotation
        let destinationAnnotation = MAPointAnnotation()
        destinationAnnotation.coordinate = self.destinationCoordinate
        destinationAnnotation.title = RoutePlanningViewControllerDestinationTitle
        destinationAnnotation.subtitle = "{\(self.destinationCoordinate.latitude), \(self.destinationCoordinate.longitude)}"
        self.destinationAnnotation = destinationAnnotation
        self.mapView.addAnnotation(startAnnotation)
        self.mapView.addAnnotation(destinationAnnotation)
    }
    
    //驾车路线开始规划
    func searchRoutePlanningDrive() {
        let navi = AMapDrivingRouteSearchRequest()
        navi.requireExtension = true
        navi.strategy = 5
        //驾车导航策略,5-多策略（同时使用速度优先、费用优先、距离优先三个策略）
        /* 出发点. */
        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(self.startCoordinate.latitude), longitude: CGFloat(self.startCoordinate.longitude))
        /* 目的地. */
        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(self.destinationCoordinate.latitude), longitude: CGFloat(self.destinationCoordinate.longitude))
        self.search.aMapDrivingRouteSearch(navi)
    }
    
    
    // MARK: - AMapSearchDelegate
    
    //当路径规划搜索请求发生错误时，会调用代理的此方法
    func aMapSearchRequest(_ request: Any, didFailWithError error: Error?) {
        print("Error: \(error)")
        self.resetSearchResultAndXibViewsToDefault()
    }
    
    //路径规划搜索完成回调.
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest, response: AMapRouteSearchResponse) {
        if response.route == nil {
            self.resetSearchResultAndXibViewsToDefault()
            return
        }
        self.route = response.route
        self.totalRouteNums = self.route.paths.count
        self.currentRouteIndex = 0
        let enable = self.totalRouteNums > 0
        self.switchRouteBtn.isEnabled = enable
        self.routeDetailBtn.isEnabled = enable
        self.showTrafficSwitch.isEnabled = enable
        self.infoLabel.text = ""
        self.presentCurrentRouteCourse()
    }
    //在地图上显示当前选择的路径
    
    func presentCurrentRouteCourse() {
        if self.totalRouteNums <= 0 {
            return
        }
        self.naviRoute?.removeFromMapView() //清空地图上已有的路线
        
        self.infoLabel.text = "共\(UInt(self.totalRouteNums))条路线，当前显示第\(UInt(self.currentRouteIndex) + 1)条"  //提示信息
        
        let type = MANaviAnnotationType.drive //驾车类型
        
        let startPoint = AMapGeoPoint.location(withLatitude: CGFloat(self.startAnnotation.coordinate.latitude), longitude: CGFloat(self.startAnnotation.coordinate.longitude)) //起点
        
        let endPoint = AMapGeoPoint.location(withLatitude: CGFloat(self.destinationAnnotation.coordinate.latitude), longitude: CGFloat(self.destinationAnnotation.coordinate.longitude))  //终点
        
        //根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
        self.naviRoute = MANaviRoute(for: self.route.paths[self.currentRouteIndex], withNaviType: type, showTraffic: self.showTrafficSwitch.isOn, start: startPoint, end: endPoint)
        self.naviRoute?.add(to: self.mapView)
        
        //显示到地图上
        let edgePaddingRect = UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
        //缩放地图使其适应polylines的展示
        self.mapView.setVisibleMapRect(CommonUtility.mapRect(forOverlays: self.naviRoute?.routePolylines), edgePadding: edgePaddingRect, animated: true)
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        //虚线，如需要步行的
        if overlay.isKind(of: LineDashPolyline.self) {
            let naviPolyline: LineDashPolyline = overlay as! LineDashPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 6
            renderer.strokeColor = UIColor.red
            renderer.lineDash = true
            
            return renderer
        }
        
        //showTraffic为NO时，不需要带实时路况，路径为单一颜色，比如驾车线路目前为blueColor
        if overlay.isKind(of: MANaviPolyline.self) {
            
            let naviPolyline: MANaviPolyline = overlay as! MANaviPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 6
            
            if naviPolyline.type == MANaviAnnotationType.walking {
                renderer.strokeColor = naviRoute?.walkingColor
            }
            else if naviPolyline.type == MANaviAnnotationType.railway {
                renderer.strokeColor = naviRoute?.railwayColor;
            }
            else {
                renderer.strokeColor = naviRoute?.routeColor;
            }
            
            return renderer
        }
        
        //showTraffic为YES时，需要带实时路况，路径为多颜色渐变
        if overlay.isKind(of: MAMultiPolyline.self) {
            let renderer: MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay as! MAMultiPolyline!)
            renderer.lineWidth = 6
            renderer.strokeColors = naviRoute?.multiPolylineColors
            
            return renderer
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            
            //标注的view的初始化和复用
            let pointReuseIndetifier = "RoutePlanningCellIdentifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }
            
            annotationView!.image = nil
            
            if annotation.isKind(of: MANaviAnnotation.self) {
                let naviAnno = annotation as! MANaviAnnotation
                
                switch naviAnno.type {
                case MANaviAnnotationType.railway:
                    annotationView!.image = UIImage(named: "railway_station")
                    break
                case MANaviAnnotationType.drive:
                    annotationView!.image = UIImage(named: "car")
                    break
                case MANaviAnnotationType.riding:
                    annotationView!.image = UIImage(named: "ride")
                    break
                case MANaviAnnotationType.walking:
                    annotationView!.image = UIImage(named: "man")
                    break
                case MANaviAnnotationType.bus:
                    annotationView!.image = UIImage(named: "bus")
                    break
                }
            }
            else {
                if annotation.title == "起点" {
                    annotationView!.image = UIImage(named: "startPoint")
                }
                else if annotation.title == "终点" {
                    annotationView!.image = UIImage(named: "endPoint")
                }
            }
            return annotationView!
        }
        
        return nil
    }
    
    
    // MARK: - Xib Btn Click
    
    //重新规划按钮点击
    @IBAction func restartSearch(_ sender: Any) {
        self.searchRoutePlanningDrive()
    }
    
    //下一路线按钮点击
    @IBAction func switchRoute(_ sender: Any) {
        if self.totalRouteNums > 0 {
            if self.currentRouteIndex < self.totalRouteNums - 1 {
                self.currentRouteIndex = self.currentRouteIndex + 1
            }
            else {
                self.currentRouteIndex = 0
            }
            self.presentCurrentRouteCourse()
        }
    }
    
    //是否显示实时路况的切换
    @IBAction func switchShowTraffic(_ sender: Any) {
        self.presentCurrentRouteCourse()
    }
    
    //路线详情按钮点击
    @IBAction func goToRouteDetail(_ sender: Any) {
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
