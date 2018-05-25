FROM ubuntu:bionic-20180426

# Common stuff
RUN echo "root:cool" | chpasswd \
	&& umask 000 \
	&& apt-get update && apt-get install -y \
	sudo \
	build-essential \
	curl \
	git \
	python-pip \
	python3-pip \
	locales

# locale
RUN locale-gen en_US.UTF-8

#add appresso user
RUN useradd -ms /bin/bash appresso \
	&& adduser appresso sudo \
	&& echo "appresso:cool" | chpasswd

# Postgres
RUN umask 000 && echo "Europe/Oslo" > /etc/timezone \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib \
	&& mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 777 /var/run/postgresql \
	&& chown appresso:appresso /var/run/postgresql 

# Nodejs 9 and yarn
RUN umask 000 && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
	&& apt-get install -y nodejs \
	&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& apt-get update && apt-get install yarn

# Sass
RUN umask 000 && cd /usr/lib \
	&& curl -sL https://github.com/sass/sassc/archive/3.4.7.tar.gz | tar -zxvf - && mv sassc* sassc \
	&& curl -sL https://github.com/sass/libsass/archive/3.4.5.tar.gz | tar -zxvf - && mv libsass* libsass \
	&& curl -sL https://github.com/sass/sass-spec/archive/v3.5.4.tar.gz | tar -zxvf - && mv sass-spec* sass-spec \
	&& export SASS_LIBSASS_PATH=`pwd`/libsass \
	&& export SASS_SPEC_SASS=`pwd`/sass-spec \
	&& make -C sassc -j4 \
	&& curl -sL https://github.com/mgreter/sass2scss/archive/v1.1.0.tar.gz | tar -zxvf - && mv sass2scss* sass2scss \
	&& make -C sass2scss \
	&& echo "# Sass" >> /home/appresso/.bashrc \
	&& echo "export SASS_LIBSASS_PATH=$PWD/libsass" >> /home/appresso/.bashrc \
	&& echo "export SASS_SPEC_SASS=$PWD/sass-spec" >> /home/appresso/.bashrc \
	&& echo "PATH=$PATH:$PWD/sassc/bin:$PWD/sass2scss" >> /home/appresso/.bashrc

# Bash rc stuff and virtualenv wrapper.
RUN umask 000 \
	&& pip install virtualenvwrapper \
	&& echo "# virtualenvwrapper" >> /home/appresso/.bashrc\
	&& chmod -R 777 /home \
	&& export WORKON_HOME=/home/appresso/.virtualenvs \
	&& mkdir /home/appresso/.virtualenvs \
	&& echo "export WORKON_HOME=/home/appresso/.virtualenvs" >> /home/appresso/.bashrc \
	&& echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/appresso/.bashrc \
	&& echo "# Postgres" >> /home/appresso/.bashrc \
	&& echo "export PATH=$PATH:/usr/lib/postgresql/10/bin" >> /home/appresso/.bashrc

USER appresso

WORKDIR /home/appresso
