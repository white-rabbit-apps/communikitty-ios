#source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods

    pod 'CLImageEditor'
    pod 'CLImageEditor/StickerTool'
    pod 'CLImageEditor/TextTool'
    pod 'CLImageEditor/SplashTool'
    pod 'Eureka'
    pod 'GooglePlacesRow'
    pod 'ImageRow'
    pod 'Fusuma'
    pod 'Parse'
    pod 'Parse/UI'
    pod 'Parse/FacebookUtils'
    pod 'ActiveLabel'
    pod 'AFNetworking'
    pod "BWWalkthrough"
    pod 'CRToast'
    pod 'Device'
    pod 'DZNEmptyDataSet'
    pod 'Hoko'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'Instabug'
    pod 'Kingfisher'
    pod 'MMMarkdown'
    pod 'OAuthSwift'
    pod 'PagingMenuController'
    pod 'SKPhotoBrowser'
    pod 'SlideMenuControllerSwift'
    pod 'Alamofire'
    pod 'BTNavigationDropdownMenu'
end

target 'CommuniKitty' do
    shared_pods
end

target 'CommuniKitty Dev' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end
