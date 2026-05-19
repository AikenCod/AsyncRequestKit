Pod::Spec.new do |spec|
  spec.name         = "AsyncRequestKit"
  spec.version      = "0.3.2"
  spec.summary      = "A lightweight Swift Concurrency networking toolkit."
  spec.description  = <<-DESC
AsyncRequestKit provides a lightweight Swift Concurrency networking toolkit
with retry, timeout, request coordination, controlled parallelism, token
refresh coordination, and shared-client ergonomics.
  DESC

  spec.homepage     = "https://github.com/AikenCod/AsyncRequestKit"
  spec.license      = {
    :type => "Proprietary",
    :text => "No separate license file has been added to this repository yet."
  }
  spec.author       = { "Alex" => "Alex@qt.com" }
  spec.source       = {
    :git => "https://github.com/AikenCod/AsyncRequestKit.git",
    :tag => spec.version.to_s
  }

  spec.swift_versions = ["6.0"]
  spec.requires_arc = true

  spec.ios.deployment_target = "16.0"
  spec.osx.deployment_target = "13.0"
  spec.tvos.deployment_target = "16.0"
  spec.watchos.deployment_target = "9.0"

  spec.source_files = "Sources/AsyncRequestKit/**/*.swift"
end
