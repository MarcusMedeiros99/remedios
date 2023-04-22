start:
	@echo "Initializing postgres container" 
	@docker run --name remedios_db -e POSTGRES_PASSWORD=123 -d postgres:15.2

create_tables:
	@echo "Creating tables"
	@docker exec -i remedios_db psql -U postgres < sql/initialize.sql 

restart: clean start

clean:
	@echo "Erasing container"
	@docker rm -f remedios_db
