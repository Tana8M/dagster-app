# Setting up for development

.PHONY: help dev-ml dev-internal build-docker rmi rinternal stop-docker start-docker clean-cache clean-env clean-containers clean deploy-ml deploy-internal deploy-external deploy-daemon-dagit deploy-pipe

# ENV NAMES
VENV_INTERNAL_NAME?=env_internal

# TARGET FILES
VENV_ACTIVATE_INTERNAL?=${VENV_INTERNAL_NAME}/bin/activate

# PYTHON INTERPRETORS OF VENV
PYTHON_INTERNAL:=${VENV_INTERNAL_NAME}/bin/python3

# -------- HELP DOCS ------- #

help:
	@echo "make clean :: remove all builds, env, cached bin files."
	@echo "make dev-ml :: prepares a development environment from docker containers for ml package."
	@echo "make dev-internal :: prepares a development environment from docker containers for internal package."
	@echo "make dev-external :: prepares a development environment from docker containers for external package."
	@echo "make rinternal :: refreshes the container docker-internal for live development. Use this after saving your code to check for changes in dagit UI."
	@echo "make stop-docker :: stops running docker containers and removes volumes attached. Use this once finished developing and want to return without rebuilding all containers."
	@echo "make start-docker :: used after make stop-docker to restart built containers. Much faster to get environments loaded than doing a clean rebuild with dev-*."
	@echo "make clean :: removes all cache files, virtual environments, stops contains and removes images associated in the docker-compose.yml"

# ----------- DEVELOPING SHORTCUTS ---------- #

# DEVELOPMENT FOR INTERNAL PACKAGE
$(VENV_ACTIVATE_INTERNAL): src/internal/requirements-internal.txt src/internal/setup.py
	python -m venv $(VENV_INTERNAL_NAME)
	$(PYTHON_INTERNAL) -m pip install -U pip
	$(PYTHON_INTERNAL) -m pip install -r | grep -v '\-e' $<
	$(PYTHON_INTERNAL) -m pip install -e src/internal/.


dev-internal: $(VENV_ACTIVATE_INTERNAL) build-docker

# ----------- DOCKER COMPOSE ----------- #
build-docker: 
	docker-compose -f docker-compose.yml up --build --no-recreate -d 

rinternal:
	docker-compose -f docker-compose.yml restart -t 3 docker-internal

stop-docker:
	docker-compose -f docker-compose.yml down -v 

start-docker:
	docker-compose -f docker-compose.yml up -d

# --------------- TESTING ------------------ #

test-internal: $(VENV_ACTIVATE_INTERNAL)
	$(PYTHON_INTERNAL) -m pytest -v src/internal/tests

# -------------- CLEAN UP ---------------- #

clean-cache:
	rm -rf **/**/.vscode
	rm -rf **/**/*.eggs **/**/*.egg-info .cache **/**/.pytest_cache 
	rm -rf .mypy_cache

clean-env:
ifneq ($(wildcard $(VENV_INTERNAL_NAME)),)
	rm -rf $(VENV_ML_NAME)
endif

clean-containers:
ifneq ($(strip $(shell docker images data-ppdags_docker-dagit -q)),)
	docker-compose -f docker-compose.yml down --rmi all -t 3
endif

clean: clean-cache clean-env clean-containers