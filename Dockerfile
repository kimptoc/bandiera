FROM docker-registry.tools.pe.springer-sbm.com/springersbm/fig-env-ruby

MAINTAINER Darren Oakley <darren.oakley@macmillan.com>

# Install PhantomJS and its dependencies - needed for the test suite
RUN apt-get update && \
  cd /usr/local/share && \
  export PHANTOM_JS="phantomjs-1.9.8-linux-x86_64" && \
  curl -OL https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 && \
  tar xvjf $PHANTOM_JS.tar.bz2 && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/share/phantomjs && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/bin/phantomjs
