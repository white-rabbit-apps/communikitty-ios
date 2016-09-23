White Rabbit iOS App
===============================

This is a template app, which will be able to build multiple apps with the same core features in the future, but is starting with the CommuniKitty app first.


# Contributing

## Target

When doing development, please always use the "CommuniKitty Dev" target.  This is connected to a dev server so you can add all the data you want without affecting the production data.  Please avoid using the "CommuniKitty" target for testing and especially avoid creating any dummy posts with dummy text in the data to keep production data clean and valid.

## Branching

When working on an issue, please create a new branch with a name that follows this format:

'[issue_number]-[your_github_username]-[issue_name]'

This should follow the convention of all other branches in the repository so follow those.

## Commenting

Please always comment your code as much as possible, including SwiftDoc [http://nshipster.com/swift-documentation/] style comments for functions and inline comments especially for code that may be confusing for someone else down the line.

```swift
/**
Lorem ipsum dolor sit amet.

- Parameters:
    - bat: Faulta nominus hereet.
    - bar: Consectetur adipisicing elit.

- returns: Sed do eiusmod tempor.
*/
func foo(bat: String, bar: String) -> AnyObject { ... }
```

A lot of the legacy code still needs to be updated with comments, which will happen, but please comment as much as possible from now on.


## Committing

Please prefix all commit messages with the issue number so that the commit is attached to the issue in github.  Use the following format:

```
#XXX - commit message
```

## Pull Requests

When you're done with the issue, please make a pull request to the master branch and I will evaluate, merge, and close the issue, or let you know what should be changed.



## Pod Changes

When making changes to a pod library, changes can be made to the source files in the pod directory while developing the change, but needs to be moved to a forked version of the library to finalize the changes.  That forked repo can then be referenced from the Podfile.  Please contact me about forking a new project into the git group account.

# Technologies

## Languages

- iOS 8 and later
- Swift 2


## Compiling Assets from Sketch

`python Tools/Slicer/slice.py "Design/iPhone.sketch" "White Rabbit/Assets.xcassets"`
`python Tools/Slicer/slice.py "../../../design/iPhone_new.sketch" "White Rabbit/AssetsNew.xcassets"`


## Frameworks|Tools Used

* [Eureka](https://github.com/xmartlabs/Eureka) for forms
* [BTNavigationDropdownMenu](https://github.com/PhamBaTho/BTNavigationDropdownMenu) for drop down menus
* [CRToast](https://github.com/cruffenach/CRToast) for messages bar
* [Timepiece](https://github.com/naoty/Timepiece) for time shortcuts
* [TagListView](https://github.com/xhacker/TagListView)
* [ALCameraViewController](https://github.com/AlexLittlejohn/ALCameraViewController)
* [InstagramKit](https://github.com/shyambhat/InstagramKit)
* [SlideMenuControllerSwift](https://github.com/dekatotoro/SlideMenuControllerSwift)
* [IDMPhotoBrowser](https://github.com/ideaismobile/IDMPhotoBrowser)
* [PagingMenuController](https://github.com/kitasuke/PagingMenuController)
* [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift)
* [SwiftDate](https://github.com/malcommac/SwiftDate)
* [Chameleon](https://github.com/ViccAlexander/Chameleon)
* [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)




## Frameworks|Tools To Consider

* [Neon](https://github.com/mamaral/Neon)
* [DAExpandAnimation](https://github.com/ifitdoesntwork/DAExpandAnimation)
* [FillableLoaders](https://github.com/poolqf/FillableLoaders)
* [CKWaveCollectionViewTransition](https://github.com/CezaryKopacz/CKWaveCollectionViewTransition)
* [XcodeSwiftSnippets](https://github.com/burczyk/XcodeSwiftSnippets)
* [AAFaceDetection](https://github.com/aaronabentheuer/AAFaceDetection)
* [SnapKit](https://github.com/SnapKit/SnapKit)
* [MMTextFieldEffects](https://github.com/mukyasa/MMTextFieldEffects)
* [MMTransitionEffect](https://github.com/mukyasa/MMTransitionEffect)
* [MMPaper](https://github.com/mukyasa/MMPaper)
* [MMGooglePlayNewsStand](https://github.com/mukyasa/MMGooglePlayNewsStand)
* [Dollar.swift](https://github.com/ankurp/Dollar.swift)
* [SFFocusViewLayout](https://github.com/fdzsergio/SFFocusViewLayout)
* [VideoSplash](https://github.com/toygar/VideoSplash)
* [EZSwipeController](https://github.com/goktugyil/EZSwipeController)
* [PureLayout](https://github.com/PureLayout/PureLayout)
* [animated-tab-bar](https://github.com/Ramotion/animated-tab-bar)
* [SlackTextViewController](https://github.com/slackhq/SlackTextViewController/tree/swift-example)
* [PermissionScope](https://github.com/nickoneill/PermissionScope)
* [Spring](https://github.com/MengTo/Spring)
* [Laurine](https://github.com/JiriTrecak/Laurine)
* [C4iOS](https://github.com/C4Framework/C4iOS)
* [XLActionController](https://github.com/xmartlabs/XLActionController)
* [PKHUD](https://github.com/pkluz/PKHUD)
* [ImagePicker](https://github.com/hyperoslo/ImagePicker)
* [MPParallaxView](https://github.com/DroidsOnRoids/MPParallaxView)
* [gifu](https://github.com/kaishin/gifu)
* [AnimatedTransitionGallery](https://github.com/shu223/AnimatedTransitionGallery)
* [CBZSplashView](https://github.com/callumboddy/CBZSplashView)
* [ZLSwipeableView](https://github.com/zhxnlai/ZLSwipeableView)
* [RZTransitions](https://github.com/Raizlabs/RZTransitions)
* []()

