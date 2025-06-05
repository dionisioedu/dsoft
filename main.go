// main.go
package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/sqlserver"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/microsoft/go-mssqldb"
)

var (
	db *sql.DB

	port         = 1433
	server       = os.Getenv("DB_SERVER")
	user         = os.Getenv("DB_USER")
	password     = os.Getenv("DB_PASSWORD")
	databaseName = os.Getenv("DB_NAME")
)

// runMigrations aplica todas as migrations na pasta ./migrations
func runMigrations() error {
	// Formata a URL para o migrate
	dbURL := fmt.Sprintf(
		"sqlserver://%s:%s@%s:%d?database=%s&encrypt=true&TrustServerCertificate=true&loginTimeout=30",
		user, password, server, port, databaseName,
	)

	// Inicializa o migrate apontando para a pasta de migrations
	m, err := migrate.New(
		"file://./migrations",
		dbURL,
	)
	if err != nil {
		return fmt.Errorf("failed to initialize migrate: %w", err)
	}
	// Executa todas as migrations 'up'
	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("migration failed: %w", err)
	}
	return nil
}

// pingHandler responde "Hello, world!" em GET /ping
func pingHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello, world!"))
}

func main() {
	// Monta a connection string para o SQL Server
	connString := fmt.Sprintf(
		"server=%s;user id=%s;password=%s;port=%d;database=%s;",
		server, user, password, port, databaseName,
	)

	var err error
	db, err = sql.Open("sqlserver", connString)
	if err != nil {
		log.Fatalf("Error creating connection pool: %s\n", err.Error())
	}
	defer db.Close()

	// Verifica a conexão com um PingContext
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err = db.PingContext(ctx); err != nil {
		log.Fatalf("Database ping failed: %s\n", err.Error())
	}
	log.Println("Connected to Azure SQL!")

	// Executa as migrations
	if err := runMigrations(); err != nil {
		log.Fatalf("Migration error: %v\n", err)
	}
	log.Println("Migrations applied successfully.")

	// Cria o router e middleware
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	// Endpoint de teste
	r.Get("/ping", pingHandler)

	// Inicia o servidor HTTP
	addr := ":8080"
	log.Printf("Starting server on %s...\n", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatalf("ListenAndServe error: %v\n", err)
	}
}
