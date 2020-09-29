default: help

# LOAD ENV
cnf ?= .make.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# COLORS
BLACK				:= $(shell tput -Txterm setaf 0)
RED         := $(shell tput -Txterm setaf 1)
GREEN       := $(shell tput -Txterm setaf 2)
YELLOW      := $(shell tput -Txterm setaf 3)
LIGHTPURPLE := $(shell tput -Txterm setaf 4)
PURPLE      := $(shell tput -Txterm setaf 5)
BLUE        := $(shell tput -Txterm setaf 6)
WHITE       := $(shell tput -Txterm setaf 7)
RESET 			:= $(shell tput -Txterm sgr0)

# set target color
TARGET_COLOR := $(BLUE)


$(info ${YELLOW}Deployment Information${RESET})
$(info ${GREEN}- CLIENT_DIR    : $(CLIENT_DIR) ${RESET})
$(info ${GREEN}- SERVER_DIR    : $(SERVER_DIR) ${RESET})
$(info ${GREEN}- NGINX_DIR     : $(NGINX_DIR) ${RESET})
$(info ${GREEN}- WORKER_DIR    : $(WORKER_DIR) ${RESET})
$(info ${GREEN}- DEPLOYMENT_DIR: $(DEPLOYMENT_DIR) ${RESET})


.PHONY: help
help: ## - help instructions
	@printf "${TARGET_COLOR}Usage: make [target]${RESET} \n"	
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\${WHITE}%-30s\${RESET} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

lint: ## - lint code
	@printf "${TARGET_COLOR}Lint code !!${RESET} \n"

clean: ## - Prune docker resources
	@echo "${TARGET_COLOR}Prune docker resources.....${RESET}"
	docker container prune -f;\
	docker image prune -f;\
	docker volume prune -f;\
	docker network prune -f;\
	docker ps -a

start: ## - Start docker compose (Example: make start env=local)
ifneq (, $(findstring ${env}, local prod))   
	@echo "${TARGET_COLOR} Start docker compose !${RESET}" ;
	make clean
	${DOCKER_COMPOSE_CMD} --env-file ${DOCKER_COMPOSE_ENV_FILE} -f $(DOCKER_COMPOSE_FILE) up
else
	@echo "${RED}Missing args${RESET}: env=local or env=prod"
	@echo "${TARGET_COLOR}Example${RESET}: make start env=local"
endif

down: ## - Stop docker-compose and remove container  (Example: make down env=local)
	$(DOCKER_COMPOSE_CMD) --env-file ${DOCKER_COMPOSE_ENV_FILE} -f $(DOCKER_COMPOSE_FILE) down
