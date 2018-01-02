Pod::Spec.new do |s|
  s.name         = "RijndaelSwift"
  s.version      = "0.1.0"
  s.summary      = "Simple Rijndael implementation in Swift"
  s.description  = <<-DESC
    Simple Rijndael implementation in Swift, support key size in [128, 192, 256], block size in [128, 192, 256].
  DESC
  s.homepage     = "https://github.com/superk589/RijndaelSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "superk" => "superk589@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/superk589/RijndaelSwift.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
