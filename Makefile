SHELL='/bin/bash'

composer-install-dev:
	make custom-composer-docker-run COMMAND="install"

composer-install-production:
	make custom-composer-docker-run COMMAND="install --no-dev"

composer-require:
	make custom-composer-docker-run COMMAND="require --update-no-dev"

composer-require-dev:
	make custom-composer-docker-run COMMAND="require --dev"

composer-update:
	make custom-composer-docker-run COMMAND="update --no-dev"

composer-remove:
	make custom-composer-docker-run COMMAND="remove --update-no-dev $(PACKAGE)"

test-unit:
	make unit-test-docker-run RUNPATH="$(FILE)"

test-unit-all:
	make unit-test-docker-run RUNPATH="mvc_tests"

test-integration-all:
	make composer-install-dev
	make docker-build-test
	@docker run \
		--rm \
		--tty \
		--interactive \
		--volume "$(PWD)":/app \
		--workdir /app \
		unit-test php mvc_tests/Integration/services.php

code-standards-fix-build:
	@docker build \
			--quiet \
			--tag php-cs-fixer \
			make/php-cs-fixer

code-standards-fix:
	make code-standards-fix-build
	docker run \
			--rm \
			--tty \
			--interactive \
			--volume "$(PWD)":/app \
			--workdir /app \
			php-cs-fixer /tmp/vendor/bin/php-cs-fixer fix $(FILE)

dump-autoload:
	@docker run \
			--rm \
			--tty \
			--interactive \
			--volume "$(PWD)":/app \
			--workdir /app/mvc/classmap \
			composer/composer:1.0 dumpautoload

custom-composer-docker-run:
	@docker run \
			--rm \
			--tty \
			--interactive \
			--volume "$(PWD)":/app \
			--user $(shell id -u):$(shell id -g) \
			composer ${COMMAND}

unit-test-docker-run:
	make composer-install-dev
	make docker-build-test
	@docker run \
			--rm \
			--tty \
			--interactive \
			--volume "$(PWD)":/app \
			--workdir /app \
			unit-test vendor/bin/phpunit ${RUNPATH}

docker-build-test:
	@docker build \
			--quiet \
			--tag unit-test \
			make/test

docker-build-cli:
	@docker build \
			--quiet \
			--tag cli \
			make/cli


cli-run:
	make docker-build-cli
	@docker run \
			--rm \
			--tty \
			--interactive \
			--volume "$(PWD)":/app \
			--workdir /app \
			--user $(shell id -u):$(shell id -g) \
			cli php mvc/protected/console/application.php ${COMMAND}
