//
//  MapManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit



class MapManager {
    //swift에서 singleton 사용하는 방법
    static let sharedInstance = MapManager()
    private init() {}

    public static let NO_MAP = -1
     public static let NAVER_MAP = 0
     public static let GOOGLE_MAP = 1
     //public let OFFLINE_MAP = 2
    
    private var mapContainer: UIView?
    
    private var activeMapClient: MapClient?
    private var activeMapRenderer: IMapRenderer?
    
    
    public func initMapClientAndRenderer() {
        var activeMap: Int = UserDefaultManager.getCurrentMapOption()
        
        //한국에 있지 않은 경우
        if (!UserInfoManager.isUserInKorea()) {
            if (activeMap == MapManager.NO_MAP) {
                activeMap = MapManager.GOOGLE_MAP;
                UserDefaultManager.saveCurrentMapOption(mapOption: MapManager.GOOGLE_MAP);
            }
        } else {
            if (activeMap == MapManager.NO_MAP) {
                activeMap = MapManager.NAVER_MAP;
                UserDefaultManager.saveCurrentMapOption(mapOption: MapManager.NAVER_MAP);
            }
        }

        setActiveMapClientAndRenderer(mapOption: activeMap);
        
    }
    
    
    public func setMapContainer(mapContainer: UIView) {
        self.mapContainer = mapContainer
    }
    
    func setActiveMapClientAndRenderer(mapOption: Int) {
        
                switch (mapOption) {
                case MapManager.NAVER_MAP:
                        activeMapClient = NaverMapClient()
                     
                        break;
                case MapManager.GOOGLE_MAP:
                        activeMapClient = GoogleMapClient()
                         break;
                    default:
                        activeMapClient = GoogleMapClient()
                        break;
                }
        
        activeMapClient?.createMap(mapContainer: mapContainer!)
        
        activeMapRenderer = activeMapClient?.getRenderer()
        

//        final MapClient finalMapClient = mapClient;
//        mapClient.createMap(new MapReadyListener() {
//
//            @Override
//            public void onMapReady() {
//                activeMapRenderer = finalMapClient.getRenderer();
//                ((MapReadyListener) context).onMapReady();
//            }
//
//            @Override
//            public void onMapNotAvailable() {
//                SharedPreferencesManager.saveCurrentMapOption(context.getApplicationContext(), MapManager.GOOGLE_MAP);
//                initMapClientAndRenderer();
//            }
//        });
//
//        activeMapClient = mapClient;
    }
    
    
    func getActiveMapClient() -> MapClient? {
        return activeMapClient
    }
    
    func getActiveMapRenderer() -> IMapRenderer? {
        return activeMapRenderer
    }
    
}
