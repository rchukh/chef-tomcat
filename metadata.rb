name             'tomcat'
maintainer       'Todd Michael Bushnell'
maintainer_email 'toddmichael@gmail.com'
license          'Apache 2.0'
description      'Installs Tomcat from binary distribution'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.15.13'

supports 'centos'

depends 'ark'
depends 'java'
