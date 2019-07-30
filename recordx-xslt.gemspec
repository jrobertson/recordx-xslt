Gem::Specification.new do |s|
  s.name = 'recordx-xslt'
  s.version = '0.2.0'
  s.summary = 'Transforms a RecordX type of schema with an XSLT schema mapping to generate an XSLT document.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/recordx-xslt.rb'] 
  s.add_runtime_dependency('c32', '~> 0.2', '>=0.2.0')  
  s.signing_key = '../privatekeys/recordx-xslt.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/recordx-xslt'
  s.required_ruby_version = '>= 2.1.2'
end
