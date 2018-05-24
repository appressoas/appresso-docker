FROM ubuntu:bionic-20180426

RUN apt-get update && apt-get install -y \
	build-essential \
	curl \
	git \
	python-pip \
	python3-pip \
	&& curl -sL https://deb.nodesource.com/setup_9.x | bash - \
	&& apt-get install -y nodejs \
	&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& apt-get update && apt-get install yarn \
	&& cd /usr/lib \
	&& curl -sL https://github.com/sass/sassc/archive/3.4.7.tar.gz | tar -zxvf - && mv sassc* sassc \
	&& curl -sL https://github.com/sass/libsass/archive/3.4.5.tar.gz | tar -zxvf - && mv libsass* libsass \
	&& curl -sL https://github.com/sass/sass-spec/archive/v3.5.4.tar.gz | tar -zxvf - && mv sass-spec* sass-spec \
	&& export SASS_LIBSASS_PATH=`pwd`/libsass \
	&& export SASS_SPEC_SASS=`pwd`/sass-spec \
	&& make -C sassc -j4 \
	&& curl -sL https://github.com/mgreter/sass2scss/archive/v1.1.0.tar.gz | tar -zxvf - && mv sass2scss* sass2scss \
	&& make -C sass2scss \
	&& echo "# Sass" >> ~/.bashrc \
	&& echo "export SASS_LIBSASS_PATH=$PWD/libsass" >> ~/.bashrc \
	&& echo "export SASS_SPEC_SASS=$PWD/sass-spec" >> ~/.bashrc \
	&& echo "PATH=$PATH:$PWD/sassc/bin:$PWD/sass2scss" >> ~/.bashrc \
	&& pip install virtualenvwrapper \
	&& echo "# virtualenvwrapper" >> ~/.bashrc \
	&& export WORKON_HOME=~/virtualenvs \
	&& mkdir ~/virtualenvs \
	&& echo "export WORKON_HOME=~/virtualenvs" >> ~/.bashrc \
	&& echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc

WORKDIR .
