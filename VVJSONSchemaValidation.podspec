Pod::Spec.new do |s|
  s.name = 'VVJSONSchemaValidation'
  s.version = '1.3.0'
  s.authors = {'Vlas Voloshin' => 'argentumko@gmail.com'}
  s.homepage = 'https://github.com/vlas-voloshin/JSONSchemaValidation'
  s.social_media_url = 'https://twitter.com/argentumko'
  s.summary = 'JSON Schema draft 4 parsing and validation library written in Objective C.'
  s.source = {:git => 'https://github.com/vlas-voloshin/JSONSchemaValidation.git', :tag => '1.3.0'}
  s.license = 'MIT'

  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'VVJSONSchemaValidation/*.{h,m}'
end
