# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'TrackerUIKit' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TrackerUIKit
  pod 'GoogleMaps', '6.1.0'
  pod 'RealmSwift', '~>10'
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'

  target 'TrackerUIKitTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TrackerUIKitUITests' do
    # Pods for testing
  end

  post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

end
