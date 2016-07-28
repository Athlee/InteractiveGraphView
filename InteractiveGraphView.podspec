Pod::Spec.new do |s|

  s.name         = "InteractiveGraphView"
  s.version      = "0.0.1"
  s.summary      = "An interactive graph view. Made easy."
  s.homepage     = "https://github.com/Athlee/InteractiveGraphView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Eugene Mozharovsky" => "mozharovsky@live.com" }
  s.social_media_url   = "http://twitter.com/dottieyottie"
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/Athlee/InteractiveGraphView.git", :tag => s.version }
  s.source_files  = "Source/*.swift"
  s.requires_arc = true

end
