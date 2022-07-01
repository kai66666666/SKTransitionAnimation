# SKTransitionAnimation
自定义转场动画

pod 'SKTransitionAnimation'

import SKTransitionAnimation

let viewCtrl = UIViewController()

self.skPresentViewController(viewCtrl, animationType: .fade)

or

self.navigationController?.skPushViewController(viewCtrl, animationType: .fade)
