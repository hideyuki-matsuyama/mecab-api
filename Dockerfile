# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=4.0.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && apt-get install -y ruby-dev && \
    apt-get install --no-install-recommends -y build-essential git pkg-config libmecab-dev libyaml-dev \
    mecab mecab-ipadic-utf8 curl xz-utils file sudo patch

# mecab-ipadic-neologd のインストール
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git /tmp/neologd && \
    cd /tmp/neologd && \
    ./bin/install-mecab-ipadic-neologd -n -y -p /var/lib/mecab/dic/mecab-ipadic-neologd && \
    cd /rails && \
    rm -rf /tmp/neologd

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Final stage for app image
FROM base AS development

# Install packages needed for deployment
# Added mecab, libmecab-dev, mecab-ipadic-utf8 for MeCab support
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libsqlite3-0 \
    mecab \
    libmecab-dev \
    mecab-ipadic-utf8 \
    git \
    build-essential \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# build ステージで生成した辞書ディレクトリだけをコピーしてデフォルトに辞書指定する
COPY --from=build /var/lib/mecab/dic/mecab-ipadic-neologd /var/lib/mecab/dic/mecab-ipadic-neologd
RUN sed -i 's/dicdir = .*$/dicdir = \/var\/lib\/mecab\/dic\/mecab-ipadic-neologd/' /etc/mecabrc

RUN git config --global --add safe.directory /rails

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
# EXPOSE 3001