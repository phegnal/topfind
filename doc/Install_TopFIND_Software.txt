INSTALLING TOPFIND
Ruby 1.8.7
install using rvm
rvm install 1.8.7
rvm --default use 1.8.7
(or install ruby 1.8.7 directly)
in WINDOWS - put ruby/bin to your path so that you can call it from the command line

gems version 1.3.7
rvm rubygems 1.3.7 —force
-if you don’t have rvm (windows) you can do:
gem install -v 1.3.7 rubygems-update
ruby rubygems-update

Rails 2.3.11
gem install -v=2.3.11 rails
- start server using “rails scripts/start”
http://www.rubydoc.info/docs/rails/2.3.8/frames

other gems:
hobo (1.0.2)
fastercsv (1.5.4)
mysql (2.8.1) - see below
bio (1.4.3)
nokogiri - NOT NEEDED - comment “require nokogiri" in environment.rb and merops.rb
paperclip (2.3.8)- NOT NEEDED - comment in environment.rb
rails (2.3.11)
builder (3.0.4)
thin (1.2.8)
delayed_jobs (2.0.4) # this also requires installation of https://github.com/collectiveidea/delayed_job/tree/v2.0
—— these should be enough to have the database running, additionally you might need (at the bottom is a full list of gems i have installed)
rserve-client (0.3.1)
rubystats (0.2.3)
biomart (0.2.3)


MYSQL:
http://www.macminivault.com/mysql-mountain-lion/
http://www.cyberciti.biz/faq/import-mysql-dumpfile-sql-datafile-into-my-database/
Needed brew to install mysql
brew install -v=2.8.1 mysql
gem install -v=2.8.1 mysql
download mysql from: http://clipserve.clip.ubc.ca/topfind/download
copy libmysql.dll into ruby/bin if mysql doesn’t work like that.
Maybe you will also need to install the mysql2 gem instead of mysql and use the mysql2 adaptor in “config/database.yml”

Now you need to go into the TopFIND application and find the files in 
/config that are “_example” and configure them to your system and Save as the same name without _example.

Start the server
thin --prefix /topfind start
http://localhost:3000/topfind
also needs to start the delayed_jobs, that is done by “rake jobs:work” 
	
also needs to start the delayed_jobs, that is done by “rake jobs:work” 

Other things:
1. "ruby script/console” to start the rails console
2. rake -T to see if rake works. If not, might have to change Rake setup:
In some versions this might be necessar:
change rake/rdoctask to  
  begin
    require 'rake/rdoctask'
  rescue
    require 'rdoc/task'
  end


RSERVE
To run TopFINDer you need to be able to run R server:
That means you have to be able to run this script:

“library(Rserve)
Rserve(args="--no-save”)” 
in R



——————————————
RUBY GEMS:
——————————————


GEMS ON NIK’s COMPUTER:
actionmailer (2.3.18, 2.3.11)
actionpack (2.3.18, 2.3.11)
activerecord (2.3.18, 2.3.11)
activeresource (2.3.18, 2.3.11)
activesupport (2.3.18, 2.3.11)
bio (1.4.3)
biomart (0.2.3)
builder (3.2.2)
bundler (1.6.2)
bundler-unload (1.0.2)
daemons (1.1.9)
delayed_job (2.0.4)
eventmachine (1.0.3)
executable-hooks (1.3.1)
gem-wrappers (1.2.4)
hobo (1.0.2)
hobofields (1.0.2)
hobosupport (1.0.2)
httpi (2.2.7)
i18n (0.6.9)
json (1.8.1, 1.5.5)
mail (2.2.15)
mime-types (1.25.1)
mini_portile (0.6.0)
minitest (5.3.3)
mysql (2.8.1)
nori (2.4.0)
passenger (5.0.6)
pdfkit (0.6.2)
polyglot (0.3.5)
rack (1.1.6)
rails (2.3.11)
rake (10.3.0, 0.8.7)
rdoc (4.1.1)
rserve-client (0.3.1)
rubygems-bundler (1.4.3)
rubystats (0.2.3)
rvm (1.11.3.9)
thin (1.2.8)
thread_safe (0.3.3)
treetop (1.4.15)
tzinfo (1.1.0)
will_paginate (2.3.16)
wkhtmltopdf-binary (0.9.9.3)



GEMS ON XSERVE 10.6
actionmailer (2.3.18, 2.3.11, 2.3.10, 2.3.8, 2.3.5, 2.3.4, 2.2.2, 1.3.6)
actionpack (2.3.18, 2.3.11, 2.3.10, 2.3.8, 2.3.5, 2.3.4, 2.2.2, 1.13.6)
actionwebservice (1.2.6)
activerecord (2.3.18, 2.3.11, 2.3.10, 2.3.8, 2.3.5, 2.3.4, 2.2.2, 1.15.6)
activeresource (2.3.18, 2.3.11, 2.3.10, 2.3.8, 2.3.5, 2.3.4, 2.2.2)
activesupport (3.2.3, 2.3.18, 2.3.11, 2.3.10, 2.3.8, 2.3.5, 2.3.4, 2.2.2, 1.4.4)
acts-as-taggable-on (2.0.6, 2.0.3)
acts_as_ferret (0.5.2, 0.4.8.1, 0.4.4, 0.4.3)
arel (2.0.9, 2.0.8)
bio (1.4.3, 1.4.1)
biomart (0.2.2)
builder (3.0.0, 2.1.2)
bundler (1.0.10)
capistrano (2.5.21, 2.5.19, 2.5.10, 2.5.2)
cgi_multipart_eof_fix (2.5.0)
cmdparse (2.0.3)
commander (4.0.4)
daemon_controller (0.2.5)
daemons (1.1.0, 1.0.10)
delayed_job (2.0.4)
dnssd (1.4, 1.3.1, 0.6.0)
erubis (2.6.6)
eventmachine (0.12.10)
fastercsv (1.5.4)
fastthread (1.0.7, 1.0.1)
fcgi (0.8.8, 0.8.7)
ferret (0.11.8.5, 0.11.6)
file-tail (1.0.5)
formtastic (1.2.2, 0.9.8)
gem_plugin (0.2.3)
highline (1.6.1, 1.5.2, 1.5.1, 1.5.0)
hike (1.2.1)
hobo (1.0.2)
hobofields (1.0.2)
hobosupport (1.0.2)
hpricot (0.8.3, 0.8.2, 0.6.164)
i18n (0.6.0, 0.5.0)
jk-ferret (0.11.8.2)
json (1.5.5)
juicer (1.0.13)
kgio (2.6.0)
libxml-ruby (1.1.4, 1.1.3, 1.1.2)
mail (2.2.15)
mime-types (1.16)
mongrel (1.1.5)
multi_json (1.2.0)
mysql (2.8.1)
needle (1.3.0)
net-scp (1.0.4, 1.0.2, 1.0.1)
net-sftp (2.0.5, 2.0.4, 2.0.1, 1.1.1)
net-ssh (2.0.24, 2.0.23, 2.0.16, 2.0.4, 1.1.4)
net-ssh-gateway (1.0.1, 1.0.0)
nokogiri (1.5.0, 1.4.4)
paperclip (2.3.8)
parseconfig (0.5.2)
passenger (3.0.9, 2.2.7)
polyglot (0.3.1)
prawn (0.8.4, 0.7.1, 0.6.3)
prawn-core (0.8.4, 0.7.1, 0.6.3)
prawn-format (0.2.3)
prawn-layout (0.8.4, 0.7.1, 0.3.2)
prawn-security (0.8.4, 0.7.1, 0.1.1)
rack (1.1.6, 1.1.0, 1.0.1)
rack-mount (0.6.13)
rack-test (0.5.7)
rails (2.3.18, 2.3.8, 2.3.5, 2.2.2, 1.2.6)
rainbows (4.3.1)
raindrops (0.7.0)
rake (0.8.7, 0.8.3)
RedCloth (4.2.9, 4.2.7, 4.2.3, 4.2.2, 4.1.1)
rserve-client (0.3.1)
rsruby (0.5.1.1)
ruby-openid (2.1.8, 2.1.7, 2.1.2)
ruby-yadis (0.3.4)
rubygems-update (1.3.7, 1.3.5)
rubynode (0.1.5)
rubystats (0.2.3)
rubyzip (0.9.4)
searchlogic (2.5.4, 2.4.27, 2.4.12)
sprockets (2.0.2)
spruz (0.2.2)
sqlite3-ruby (1.2.5, 1.2.4)
termios (0.9.4)
thin (1.2.8)
thor (0.14.6)
tilt (1.3.3)
treetop (1.4.9)
tzinfo (0.3.24)
unicorn (4.1.1)
will_paginate (2.3.15, 2.3.12)
xmpp4r (0.4)
