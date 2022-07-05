Pod::Spec.new do |s|
  s.name             = 'SKTransitionAnimation'
  s.version          = '1.1'
  s.summary          = '自定义转场动画.'
  s.homepage         = 'https://github.com/kai66666666/SKTransitionAnimation.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '孙凯' => '284035051@qq.com' }
  s.source           = { :git => 'https://github.com/kai66666666/SKTransitionAnimation.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'file/*.swift'
  s.swift_versions = ['5.0']
  s.dependency 'SKAnimationDelegate'

end
