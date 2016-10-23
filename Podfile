source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods

    pod 'CLImageEditor', :git => 'https://github.com/white-rabbit-apps/CLImageEditor.git', :branch => 'master'
    pod 'CLImageEditor/StickerTool', :git => 'https://github.com/white-rabbit-apps/CLImageEditor.git', :branch => 'master'
    pod 'CLImageEditor/TextTool', :git => 'https://github.com/white-rabbit-apps/CLImageEditor.git', :branch => 'master'
    pod 'CLImageEditor/SplashTool', :git => 'https://github.com/white-rabbit-apps/CLImageEditor.git', :branch => 'master'
    pod 'Eureka', :git => 'https://github.com/white-rabbit-apps/Eureka.git', :branch => 'master'
#    pod 'GooglePlacesRow', :git => 'https://github.com/white-rabbit-apps/GooglePlacesRow', :branch => 'master'
    pod 'GooglePlacesRow', :git => 'https://github.com/EurekaCommunity/GooglePlacesRow.git', :commit => 'b56ff3c'
    pod 'ImageRow', :git => 'https://github.com/EurekaCommunity/ImageRow.git', :branch => 'master'

    pod 'Fusuma', :git => 'https://github.com/Ferrick90/Fusuma.git', :branch => 'swift3'
#    pod 'Fusuma', :git => 'https://github.com/white-rabbit-apps/Fusuma', :branch => 'master'

    pod 'Parse', '~> 1.13.0'
    pod 'ParseUI'
    pod 'ParseFacebookUtilsV4', :git => 'https://github.com/white-rabbit-apps/ParseFacebookUtils-iOS.git', :branch => 'master'
#    pod 'ParseTwitterUtils'
    
    pod 'ActiveLabel', :git => 'https://github.com/optonaut/ActiveLabel.swift.git', :branch => 'swift-3'
    pod 'AFNetworking', '~> 3.0'
    pod 'BGTableViewRowActionWithImage'
    pod 'BWWalkthrough', :git => 'https://github.com/willeeklund/BWWalkthrough.git', :branch => 'master'
    pod 'CRToast'
    pod 'Device'
    pod 'DZNEmptyDataSet'
    pod 'Hoko'
    pod 'FBSDKCoreKit', :git => 'https://github.com/facebook/facebook-ios-sdk.git', :tag => 'sdk-version-4.16.1'
    pod 'FBSDKLoginKit', :git => 'https://github.com/facebook/facebook-ios-sdk.git', :tag => 'sdk-version-4.16.1'
    pod 'Instabug', :git => 'https://github.com/Instabug/Instabug-iOS.git', :tag => '6.0.3'
    pod 'Kingfisher', :git => 'https://github.com/onevcat/Kingfisher.git', :tag => '3.0.1'
    pod 'MMMarkdown'
    pod 'OAuthSwift', :git => 'https://github.com/skedgo/OAuthSwift/', :branch => 'swift3.0'
    pod 'PagingMenuController', :git => 'https://github.com/kitasuke/PagingMenuController.git', :branch => 'swift3.0'
    pod 'SKPhotoBrowser', :git => 'https://github.com/white-rabbit-apps/SKPhotoBrowser.git', :branch => 'swift3'
    pod 'SlideMenuControllerSwift', :git => 'https://github.com/dekatotoro/SlideMenuControllerSwift.git', :tag => '3.0.0'
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
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
