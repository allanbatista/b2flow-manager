FROM ruby:2.6.5

ENV HOME_APP=/opt/app
RUN mkdir -p ${HOME_APP}
WORKDIR ${HOME_APP}
COPY . ${HOME_APP}

RUN bundle install

CMD ["bundle", "exec", "exe/b2flow-manager"]