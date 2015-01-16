#
# Be sure to run `pod lib lint EPImageMetaDataParser.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EPImageMetaDataParser"
  s.version          = "0.1.1"
  s.summary          = "Parse Image Metadata at a given URL with minimum data being downloaded."
  s.description      = <<-DESC
                       Parse Image Metadata at a given URL with minimum data being downloaded. Built for Mac and iOS.
                       DESC
  s.homepage         = "https://github.com/eyeplum/EPImageMetaDataParser"
  s.license          = 'MIT'
  s.author           = { "Yan Li" => "eyeplum@gmail.com" }
  s.source           = { :git => "https://github.com/eyeplum/EPImageMetaDataParser.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/eyeplum'

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{h,m}'
  s.resource_bundles = {
    'EPImageMetaDataParser' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'ImageIO'
end
