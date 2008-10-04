XSS Killer
==========

XSS Killer protects Rails apps from XSS vulnerabilities without h, sanitize, or taint/untaint proliferation.

how it works
------------

XSS Killer will escape ActiveRecord string and text attributes when they're being read in an html view. When reading attributes in any other context, the model will return the original values as stored in the database.

installing as a gem
-------------------

In environment.rb:

    config.gem "xss\_killer", "0.1.0"

usage
-----

For specific models:

    class SomeModel < ActiveRecord::Base
      kills\_xss :allow_injection => [:name], :sanitize => [:description, :body]
    end
    
For all models:

    class ActiveRecord::Base
      kills\_xss
    end

requirements
------------

Rails >= 2.0

maintainer
----------

[Dan Manges](http://www.dcmanges.com/blog)

source
------

hosted on [github](http://github.com/dan-manges/xss_killer/tree/master)

license
-------

Released under [Ruby's license](http://www.ruby-lang.org/en/LICENSE.txt)
