Pod::Spec.new do |spec|
  spec.name                  = 'AsyncMessagesViewController'
  spec.version               = '0.1'
  spec.license               =  { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage              = 'https://github.com/nguyenhuy/AsyncMessagesViewController'
  spec.authors               = { 'Huy Nguyen' => 'http://huytnguyen.me' }
  spec.summary               = 'A smooth, responsive and flexible messages UI library for iOS apps.'
  spec.source                = { :path => '.'}
  spec.source_files          = 'Source/**/*.swift'
  spec.module_name           = 'AsyncMessagesViewController'
  spec.header_dir            = 'AsyncMessagesViewController'
  spec.documentation_url     = 'https://github.com/nguyenhuy/AsyncMessagesViewController'
  spec.platform              = :ios
  spec.ios.deployment_target = '9.0'
  spec.requires_arc          = true  

  #spec.ios.resource_bundle   = { spec => 'Source/Assets/AsyncMessagesViewController.xcassets' }
  spec.resource_bundles = {'AsyncMessagesViewController' => ['Source/Assets/AsyncMessagesViewController.bundle/*']}
  spec.dependency            'Texture', '2.6'
  spec.dependency            'SlackTextViewController', '1.9.6'
end
