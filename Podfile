source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
target 'Example' do
    use_frameworks!

    pod 'AsyncMessagesViewController', :path => '.'
    pod 'LoremIpsum', :git => 'https://github.com/nguyenhuy/LoremIpsum.git', :branch => 'master'
end 

post_install do |installer|
	installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end    
	end
end
