//
//  com_tenkoro614ViewController.m
//  mytestapp
//
//  Created by HirokiNakamura on 2014/02/27.
//  Copyright (c) 2014年 HirokiNakamura. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MainViewController ()

@end

@implementation MainViewController {
    CLLocationManager *_locationManager;
    NSTimer *_timer;
    
    GMSMapView *_mapView;
    NSMutableData *_mData;
    NSMutableDictionary *_icons;
    NSMutableDictionary *_circles;
    BOOL _isUpdate;
    
    NSString *_selfGroupname;
    NSString *_selfDevid;
    NSString *_selfUsername;
    int _selfIconSelect;
    UIImage *_selfIconImage;
    NSString *_selfDeviceToken;
    
    float _selfLatitude;
    float _selfLongitude;
    int _selfGpsAccracy;
    
    BOOL _isStartTask;
    BOOL _isConfig;
    
    int _gpsCount;
    
    BOOL _isInApiAccess;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 地図の表示
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float centerLatitude = [defaults floatForKey:@"latitude"];
    float centerLongitude = [defaults floatForKey:@"longitude"];
    if(centerLatitude == 0 || centerLongitude == 0) {
        centerLatitude = 34.906239;
        centerLongitude = 135.804993;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:centerLatitude
                                                            longitude:centerLongitude
                                                                 zoom:14];
    _mapView = [GMSMapView mapWithFrame:self.gMapView.bounds camera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    _icons = [NSMutableDictionary dictionary];
    _circles = [NSMutableDictionary dictionary];
    
    [self.gMapView addSubview: _mapView];
    
    _locationManager = [[CLLocationManager alloc] init];
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
    } else {
        NSLog(@"Location services not available.");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _gpsCount = 0;
    _isInApiAccess = false;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _selfGroupname = [defaults stringForKey:@"groupname"];
    _selfDevid = [defaults stringForKey:@"devid"];
    _selfUsername = [defaults stringForKey:@"username"];
    _selfIconSelect = (int)[defaults integerForKey:@"iconSelect"];
    _isUpdate = [defaults boolForKey:@"isUpdate"];
//    _selfDeviceToken = [defaults stringForKey:@"deviceToken"];

    if(_selfUsername == nil || [_selfUsername isEqualToString:@""] || _selfGroupname == nil || [_selfGroupname isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"setting" sender:self];
        return;
    }
    else {
        _isConfig =  true;
    }
    
    NSString *name = _selfIconSelect == 0 ? @"father" : _selfIconSelect == 1 ? @"mother" : _selfIconSelect == 2 ? @"sun" : _selfIconSelect == 3 ? @"daughter" : @"father";
    _selfIconImage = [UIImage imageNamed:name];
    
    [self startTask];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.myViewController = self;

    NSLog(@"------- view did appear --------");
}

// 画面終了時
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopTask];
    
//    com_tenkoro614AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    appDelegate.myViewController = nil;
    
    NSLog(@"------- view did disappear --------");
    
}

- (void)startTask {
    // タイマーを生成しスタート
    _timer = [NSTimer
              scheduledTimerWithTimeInterval:5.f
              target:self
              selector:@selector(getLocations:)
              userInfo:nil
              repeats:YES];

    _gpsCount = 0;
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        // 測位開始
        [_locationManager startUpdatingLocation];
    }

    _isStartTask = true;
}

- (void)stopTask {
//    [self.indicator stopAnimating];
    
    [_timer invalidate];
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        // 測位開始
        [_locationManager stopUpdatingLocation];
        
    }
    
    _isStartTask = false;
}

- (BOOL)isStartTask {
    return _isStartTask;
}

- (BOOL)isConfig {
    return _isConfig;
}

- (IBAction)refresh:(id)sender {
    [self.indicator startAnimating];
    
    [NSTimer
     scheduledTimerWithTimeInterval:30.f
     target:self
     selector:@selector(stopIndicator:)
     userInfo:nil
     repeats:NO];
    
    NSString *api = @"http://matiawase614.herokuapp.com/api/v1/push";
    //NSString *api = @"http://localhost:3000/api/v1/push";
    
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@/%@"
                        , api
                        , [self urlencodeFromString:_selfGroupname]
                        , [self urlencodeFromString:_selfDevid]];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"Api Call url = %@", urlstr);
    
    //通信開始
    [NSURLConnection connectionWithRequest:request delegate:nil];
}

// 位置情報更新時
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
//    [_mapView animateToLocation : [newLocation coordinate]];
    
    //緯度・経度を出力
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f, horizontalAccuracy=%d, verticalAccuracy=%d",
          [newLocation coordinate].latitude,
          [newLocation coordinate].longitude,
          (int)[newLocation horizontalAccuracy],
          (int)[newLocation verticalAccuracy]);
    
    _selfLatitude = [newLocation coordinate].latitude;
    _selfLongitude = [newLocation coordinate].longitude;
    _selfGpsAccracy = (int)MAX([newLocation horizontalAccuracy],[newLocation verticalAccuracy]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:_selfLatitude forKey:@"latitude"];
    [defaults setFloat:_selfLongitude forKey:@"longitude"];
    [defaults setInteger:_selfGpsAccracy forKey:@"gpsAccuracy"];
    
//    NSLog(@"devid=%@",_selfDevid);
    
    GMSMarker *icon = [_icons objectForKey:_selfDevid];
    if(icon == nil) {
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(_selfLatitude, _selfLongitude);
        icon = [GMSMarker markerWithPosition:position];
        icon.title = _selfUsername;
        icon.icon = _selfIconImage;
        icon.userData = _selfDevid;
        icon.map = _mapView;
        [_icons setObject:icon forKey:_selfDevid];
    }
    else {
        icon.position = CLLocationCoordinate2DMake(_selfLatitude, _selfLongitude);
        icon.title = _selfUsername;
        icon.icon = _selfIconImage;
    }
    
    if(_gpsCount%5 == 0) {
        [self getLocations];
    }
    _gpsCount++;
}

// 測位失敗時や、位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}

// タイマーが動作した時の処理
- (void)getLocations:(NSTimer *)timer {
    [self getLocations];
}

- (void)getLocations {
    if(_isInApiAccess) {
        return;
    }
    
    _isInApiAccess = true;
    
    NSString *api = @"http://matiawase614.herokuapp.com/api/v1/list";
    //NSString *api = @"http://localhost:3000/api/v1/list";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _selfDeviceToken = [defaults stringForKey:@"deviceToken"];
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@/%@/%@/%i/%@/%@/%i/%@"
                        , api
                        , [self urlencodeFromString: _selfGroupname]
                        , [self urlencodeFromString: _selfDevid]
                        , [self urlencodeFromString: _selfUsername]
                        , _selfIconSelect
                        , [self urlencodeFromFloat: _selfLatitude]
                        , [self urlencodeFromFloat:_selfLongitude]
                        , _selfGpsAccracy
                        , [self urlencodeFromString:_selfDeviceToken]];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"Api Call url = %@", urlstr);
    
    //通信開始
    [NSURLConnection connectionWithRequest:request delegate:self];
}

//通信開始時に呼ばれる
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //初期化
    _mData = [NSMutableData data];
}

//通信中常に呼ばれる
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    //通信したデータを入れていきます
    [_mData appendData:data];
    
}

//通信終了時に呼ばれる
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error = nil;
    
    //NSDictinaryがNSArrayになって返ってきます(id の中に入る)
    NSArray *json = [NSJSONSerialization JSONObjectWithData:_mData options:NSJSONReadingAllowFragments error:&error];
    bool isUpdated = true;
    for(NSDictionary *dic in json) {
        NSString *devid = [dic objectForKey:@"devid"];
        NSString *username =  [dic objectForKey:@"username"];
        int iconSelect = [[dic objectForKey:@"iconSelect"] intValue];
        float latitude = [[dic objectForKey:@"latitude"] floatValue];
        float longitude = [[dic objectForKey:@"longitude"] floatValue];
        int gpsAccuracy = [[dic objectForKey:@"gpsAccuracy"] intValue];
        NSString *deviceToken =  [dic objectForKey:@"deviceToken"];
        NSString *updated_at = [dic objectForKey:@"updated_at"];
        NSLog(@"rtnData : devid=%@,username=%@,iconSelect=%i,latitude=%f,longitude=%f,deviceToken=%@,updated_at=%@",devid,username,iconSelect,latitude,longitude,deviceToken,updated_at);
        
        if(![devid isEqualToString:_selfDevid]) {
            NSString *name = iconSelect == 0 ? @"father" : iconSelect == 1 ? @"mother" : iconSelect == 2 ? @"sun" : iconSelect == 3 ? @"daughter" : @"father";
            if([self isOutOfDateLocation:updated_at]) {
                name = [NSString stringWithFormat:@"%@_b",name];
                isUpdated = false;
            }
            
            UIImage *iconImage = [UIImage imageNamed:name];
            
            GMSMarker *icon = [_icons objectForKey:devid];
            if(icon == nil) {
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
                icon = [GMSMarker markerWithPosition:position];
                icon.title = username;
                icon.icon = iconImage;
                icon.userData = devid;
                icon.map = _mapView;
                [_icons setObject:icon forKey:devid];
            }
            else {
                icon.position = CLLocationCoordinate2DMake(latitude, longitude);
                icon.title = username;
                icon.icon = iconImage;
            }
            
            GMSCircle *circle = [_circles objectForKey:devid];
            if(circle == nil) {
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
                circle = [GMSCircle circleWithPosition:position radius:gpsAccuracy];
                circle.map = _mapView;
                circle.strokeColor = [UIColor colorWithRed:0.133 green:0.545 blue:0.133 alpha:0.5];
                circle.fillColor = [UIColor colorWithRed:0.04 green:0.83 blue:0.09 alpha:0.1];
                [_circles setObject:circle forKey:devid];
            }
            else {
                circle.position = CLLocationCoordinate2DMake(latitude, longitude);
                circle.radius = gpsAccuracy;
            }
        }
    }
    if(isUpdated) {
        [self.indicator stopAnimating];
    }
    
    /*
    if(!error){
        NSLog(@"%@",json);
    }
    */
    
    _isInApiAccess = false;
}

//通信エラー時に呼ばれる
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //エラー処理を書く
    _isInApiAccess = false;
}

- (NSString *)urlencodeFromFloat:(float)value {
    NSString *tmp = [NSString stringWithFormat:@"%f", value];
    return [self urlencodeFromString: tmp];
}

- (NSString *)urlencodeFromString:(NSString *)value {
    NSString *rtn = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef)value,
                                                                                          NULL,
                                                                                          (CFStringRef)@".!*'();:@&=-+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
    return rtn;
}
       
- (void)stopIndicator:(NSTimer *)timer {
    [self.indicator stopAnimating];
}

- (BOOL)isOutOfDateLocation:(NSString *)updated_at {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" ];
    NSDate *updatedDate = [formatter dateFromString:updated_at];
    updatedDate = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:updatedDate];
    
    float interval = [[NSDate date] timeIntervalSinceDate:updatedDate];
//    NSLog(@"-------------%@-------------%@---------------%f",updatedDate,[NSDate date],interval);
    return (interval > 5.0f*60.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
