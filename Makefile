# Setting up for development

.PHONY: help dev-ml dev-etl build-docker rmi retl stop-docker start-docker clean-cache clean-env clean-containers clean deploy-ml deploy-etl deploy-external deploy-daemon-dagit deploy-pipe

# ENV NAMES
VENV_etl_NAME?=env_etl

# TARGET FILES
VENV_ACTIVATE_etl?=${VENV_etl_NAME}/bin/activate

# PYTHON INTERPRETORS OF VENV
PYTHON_etl:=${VENV_etl_NAME}/bin/python3

# -------- HELP DOCS ------- #

help:
	@echo "make clean :: remove all builds, env, cached bin files."
	@echo "make dev-ml :: prepares a development environment from docker containers for ml package."
	@echo "make dev-etl :: prepares a development environment from docker containers for etl package."
	@echo "make dev-external :: prepares a development environment from docker containers for external package."
	@echo "make retl :: refreshes the container docker-etl for live development. Use this after saving your code to check for changes in dagit UI."
	@echo "make stop-docker :: stops running docker containers and removes volumes attached. Use this once finished developing and want to return without rebuilding all containers."
	@echo "make start-docker :: used after make stop-docker to restart built containers. Much faster to get environments loaded than doing a clean rebuild with dev-*."
	@echo "make clean :: removes all cache files, virtual environments, stops contains and removes images associated in the docker-compose.yml"

# ----------- DEVELOPING SHORTCUTS ---------- #

# DEVELOPMENT FOR etl PACKAGE
$(VENV_ACTIVATE_etl): src/etl/requirements-etl.txt src/etl/setup.py
	python -m venv $(VENV_etl_NAME)
	$(PYTHON_etl) -m pip install -U pip
	$(PYTHON_etl) -m pip install -r | grep -v '\-e' $<
	$(PYTHON_etl) -m pip install -e src/etl/.


dev-etl: $(VENV_ACTIVATE_etl) build-docker

# ----------- DOCKER COMPOSE ----------- #
build-docker: 
	docker-compose -f docker-compose.yml up --build --no-recreate -d 

retl:
	docker-compose -f docker-compose.yml restart -t 3 docker-etl

stop-docker:
	docker-compose -f docker-compose.yml down -v 

start-docker:
	docker-compose -f docker-compose.yml up -d

# --------------- TESTING ------------------ #

test-etl: $(VENV_ACTIVATE_etl)
	$(PYTHON_etl) -m pytest -v src/etl/tests

# -------------- CLEAN UP ---------------- #

clean-cache:
	rm -rf **/**/.vscode
	rm -rf **/**/*.eggs **/**/*.egg-info .cache **/**/.pytest_cache 
	rm -rf .mypy_cache

clean-env:
ifneq ($(wildcard $(VENV_etl_NAME)),)
	rm -rf ${VENV_etl_NAME}
endif

clean-containers:
ifneq ($(strip $(shell docker images data-ppdags_docker-dagit -q)),)
	docker-compose -f docker-compose.yml down --rmi all -t 3
endif

clean: clean-cache clean-env clean-containers