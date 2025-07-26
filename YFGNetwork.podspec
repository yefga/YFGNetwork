Pod::Spec.new do |s|
  s.name             = 'YFGNetwork'
  s.version          = '0.1.0'
  s.summary          = 'A modern, clean, and testable networking layer for iOS and macOS.'

  s.description      = "
A Minimal networking framework built on Swift's modern concurrency (`async/await`).
Features include request interception, response validation, retry policies, and detailed logging."

  s.homepage         = 'https://github.com/Yefga/YFGNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yefga Torra' => 'yefga@naver.com' }
  s.source           = { :git => 'https://github.com/Yefga/YFGNetwork.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  
  s.swift_version = '5.5'

  # This assumes your source files are located in a "Sources/YFGNetwork" directory.
  # Adjust this path if your project structure is different.
  s.source_files = 'Sources/YFGNetwork/**/*.swift'
  
  # The framework depends on the Network framework for YFGNetworkMonitor.
  s.frameworks = 'Foundation', 'Network'

end
