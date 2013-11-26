Pod::Spec.new do |s|
  s.name         = "BSSwipeTableViewCell"
  s.version      = "1.0.0"
  s.summary      = "A very customizable table view cell which can be swiped left and right."
  s.homepage     = "https://github.com/simonbs/BSSwipeTableViewCell"
  s.license      = 'MIT'
  s.author       = { "Simon Støvring" => "simon@intuitaps.dk" }
  s.source       = { :git => "https://github.com/simonbs/BSSwipeTableViewCell.git", :tag => "1.0.0" }
  s.requires_arc = true
  s.platform     = :ios, '7.0'
  s.source_files = 'BSSwipeTableViewCell/BSSwipeTableViewCell.{h,m}'
end
