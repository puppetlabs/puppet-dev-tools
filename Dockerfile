FROM alpine

RUN apk update && apk add ruby ruby-dev alpine-sdk && \
    gem install --no-rdoc --no-ri bigdecimal \
      etc \
      io-console \
      pdk \
      onceover
