//
//  ViewController.m
//  ZMChangeLocation
//
//  Created by Miaoz on 2018/3/8.
//  Copyright © 2018年 Miaoz. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ChangeLoction.h"

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) UILabel *location2DLable;
@property (nonatomic, strong) UILabel *locationLable;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _location2DLable = [[UILabel alloc] init];
    _location2DLable.frame = CGRectMake(90, 100, 200, 100);
    _location2DLable.numberOfLines = 0;
    [self.view addSubview:_location2DLable];
    
    _locationLable = [[UILabel alloc] init];
    _locationLable.frame = CGRectMake(90, 300, 200, 100);
     _locationLable.numberOfLines = 0;
    [self.view addSubview:_locationLable];
    
    
    //如果要想知道任意位置的坐标
    //1.去高德地图http://lbs.amap.com/console/show/picker，选中自己坐标
    //杭州  120.211963,30.274602
    //2.在进行坐标转换
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(30.274602, 120.211963);
    CLLocationCoordinate2D WGSlocation2D = [ChangeLoction gcj02ToWgs84:location2D];
    NSLog(@"纬度：%f,经度：%f",WGSlocation2D.latitude , WGSlocation2D.longitude);
    //纬度：30.277029,经度：120.207428
    //3.去LocationTest.gpx修改经纬度

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    //    [manager requestAlwaysAuthorization];
    [_manager requestWhenInUseAuthorization];
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    _manager.distanceFilter = 1.0;
    [_manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    //1.如果打卡地点是这里，当前的经纬度。
    //2.直接copy下面的经纬度，无需转换
    //3.去LocationTest.gpx修改经纬度
    //当前的经纬度
    NSLog(@"当前的经纬度 %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    self.location2DLable.text = [NSString stringWithFormat:@"纬度:%f,经度:%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    
    //地理反编码 可以根据坐标(经纬度)确定位置信息(街道 门牌等)
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count >0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality;
            if (!currentCity) {
                currentCity = @"无法定位当前城市";
            }
            //看需求定义一个全局变量来接收赋值
            NSLog(@"当前国家 - %@",placeMark.country);//当前国家
            NSLog(@"当前城市 - %@",currentCity);//当前城市
            NSLog(@"当前位置 - %@",placeMark.subLocality);//当前位置
            NSLog(@"当前街道 - %@",placeMark.thoroughfare);//当前街道
            NSLog(@"具体地址 - %@",placeMark.name);//具体地址
            self.locationLable.text = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",placeMark.country,currentCity,placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
