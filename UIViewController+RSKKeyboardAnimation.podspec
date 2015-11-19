Pod::Spec.new do |s|
  s.name          = 'UIViewController+RSKKeyboardAnimation'
  s.version       = '1.0.0'
  s.summary       = 'Showing/dismissing keyboard animation in simple view controller category.'
  s.homepage      = 'https://github.com/ruslanskorb/UIViewController-RSKKeyboardAnimation'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { 'Anton Gaenko' => 'antony.gaenko@gmail.com', 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.platform      = :ios, '6.0'
  s.source        = { :git => 'https://github.com/ruslanskorb/UIViewController-KeyboardAnimation.git', :tag=> s.version.to_s }
  s.source_files  = 'UIViewController+RSKKeyboardAnimation/*.{h,m}'
  s.framework     = 'UIKit'
  s.requires_arc  = true
end
