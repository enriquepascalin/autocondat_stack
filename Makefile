.PHONY: start stop restart logs psql redisinsight rabbitmq-ui install-deps mailhog sonarqube-init quality-report

start:                       ## Build & start stack
	docker compose up -d --build

stop:                        ## Stop stack
	docker compose down

restart: stop start          ## Restart stack

install-deps:                ## Install local OS dependencies
	@echo "Instalando dependencias del sistema…"
	sudo ./scripts/install_dependencies.sh

logs:                        ## Tail application logs
	docker compose logs -f app

psql:                        ## Open psql shell
	docker compose exec db psql -U autocondat

redisinsight:
	open http://localhost:5540

rabbitmq-ui:
	open http://localhost:15672

mailhog:
	open http://localhost:8025

sonarqube-init:
	docker compose exec code-quality /app/scripts/init_sonarqube.sh

quality-report:              ## One-shot scan (Option A)
	docker run --rm \
	  --network autocondat-network \
	  -v $(PWD)/autocondat7:/src \
	  sonarsource/sonar-scanner-cli \
	  -Dsonar.projectKey=autocondat \
	  -Dsonar.sources=/src \
	  -Dsonar.host.url=http://code-quality:9000 \
	  -Dsonar.login=admin -Dsonar.password=admin
