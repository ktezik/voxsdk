
Pod::Spec.new do |s|
  s.name                   = "VOXSDK"
  s.version                = "1.0.1"
  s.summary                = "Краткое описание вашего фреймворка"
  s.homepage               = "https://github.com/ktezik/voxsdk"
  s.license                = { :type => 'MIT', :file => 'LICENSE' }
  s.author                 = { "Гришин Иван Дмитриевич" => "ktezik@ya.ru" }
  s.source                 = { :git => "https://github.com/ktezik/voxsdk.git", :tag => s.version.to_s }
  s.exclude_files          = "VOXSDK/Package.swift"
  
  s.ios.deployment_target  = "15.0"
  s.swift_version          = "5.7"
  
  s.source_files           = ['VOXSDK/**/*.{swift,h,m}', 'VOXSDK.xcodeproj']
end
