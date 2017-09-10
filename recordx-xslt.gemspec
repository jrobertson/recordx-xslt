Gem::Specification.new do |s|
  s.name = 'recordx-xslt'
  s.version = '0.1.5'
  s.summary = 'recordx-xslt'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb'] 
  s.signing_key = '../privatekeys/recordx-xslt.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/recordx-xslt'
  s.required_ruby_version = '>= 2.1.2'
end
