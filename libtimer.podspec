Pod::Spec.new do |s|
  s.name             = 'libtimer'
  s.version          = "1.0.0"
  s.summary          = "Sugar for DispatchSourceTimer"
  s.homepage         = "https://github.com/Meniny/libtimer"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = 'Elias Abel'
  s.source           = { :git => "https://github.com/Meniny/libtimer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'
  s.source_files     = "libtimer/**/*.swift"
  s.requires_arc     = true
  s.ios.deployment_target = "8"
  s.description  = "Elegant sugar for DispatchSourceTimer"
  s.module_name = 'libtimer'
end
