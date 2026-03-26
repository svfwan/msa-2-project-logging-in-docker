.PHONY: help up down down-v restart logs logs-app logs-loki logs-promtail logs-grafana ps test build clean status

# Default target
.DEFAULT_GOAL := help

# Colors for help output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RESET := \033[0m

help: ## Show this help message
	@echo ""
	@echo "$(GREEN)Docker Logging with PLG Stack$(RESET)"
	@echo ""
	@echo "$(YELLOW)Usage:$(RESET) make [target]"
	@echo ""
	@echo "$(YELLOW)Targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

up: ## Start all services
	docker compose up -d
	@echo ""
	@echo "$(GREEN)Services started!$(RESET)"
	@echo "  App:     http://localhost:8000"
	@echo "  Grafana: http://localhost:3000 (admin/admin)"
	@echo "  Loki:    http://localhost:3100"
	@echo ""
	@echo "Run '$(CYAN)make test$(RESET)' to generate some test logs"

down: ## Stop all services
	docker compose down
	@echo "$(GREEN)Services stopped$(RESET)"

down-v: ## Stop all services and remove volumes
	docker compose down -v
	@echo "$(GREEN)Services stopped and volumes removed$(RESET)"

restart: down up ## Restart all services

logs: ## Show logs from all services
	docker compose logs -f

logs-app: ## Show logs from the app service
	docker compose logs -f app

logs-loki: ## Show logs from loki
	docker compose logs -f loki

logs-promtail: ## Show logs from promtail
	docker compose logs -f promtail

logs-grafana: ## Show logs from grafana
	docker compose logs -f grafana

ps: ## Show running containers
	docker compose ps

test: ## Generate test log entries
	@echo "$(YELLOW)Generating test logs...$(RESET)"
	@echo ""
	@echo "GET /"
	@curl -s http://localhost:8000/ | head -c 100
	@echo ""
	@echo ""
	@echo "GET /hello/Alice"
	@curl -s http://localhost:8000/hello/Alice
	@echo ""
	@echo ""
	@echo "GET /hello/Bob"
	@curl -s http://localhost:8000/hello/Bob
	@echo ""
	@echo ""
	@echo "GET /hello/Charlie"
	@curl -s http://localhost:8000/hello/Charlie
	@echo ""
	@echo ""
	@echo "GET /health"
	@curl -s http://localhost:8000/health
	@echo ""
	@echo ""
	@echo "$(GREEN)Test logs generated!$(RESET)"
	@echo "View them in Grafana: http://localhost:3000"
	@echo "Query: {container=\"logging-demo-app\"}"

build: ## Build the app image
	docker compose build
	@echo "$(GREEN)Build complete$(RESET)"

clean: ## Remove all containers, volumes, and images
	docker compose down -v --rmi all
	@echo "$(GREEN)Cleanup complete$(RESET)"

status: ## Check health of all services
	@echo "$(YELLOW)Checking service health...$(RESET)"
	@echo ""
	@echo "Loki:"
	@curl -s http://localhost:3100/ready && echo " $(GREEN)OK$(RESET)" || echo " $(YELLOW)Not ready$(RESET)"
	@echo ""
	@echo "App:"
	@curl -s http://localhost:8000/health && echo " $(GREEN)OK$(RESET)" || echo " $(YELLOW)Not ready$(RESET)"
	@echo ""
	@echo "Grafana:"
	@curl -s http://localhost:3000/api/health && echo " $(GREEN)OK$(RESET)" || echo " $(YELLOW)Not ready$(RESET)"
	@echo ""
