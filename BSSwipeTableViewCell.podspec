Pod::Spec.new do |s|
  s.name = 'BSSwipeTableViewCell'
  s.version = '1.0.0'
  s.homepage = 'https://github.com/simonbs/BSSwipeTableViewCell'
  s.authors = { 'Simon Støvring' => 'simon@intuitaps.dk' }
  s.license = 'MIT'
  s.summary = 'A very customizable table view cell which can be swiped left and right.'
  s.source = { :git => 'https://github.com/simonbs/BSSwipeTableViewCell.git', :tag => '1.0.0' }
  s.source_files = 'BSSwipeTableViewCell/*.{h,m}'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
end