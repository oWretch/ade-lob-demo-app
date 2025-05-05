package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
)

type PageData struct {
	Title      string
	AppVersion string
	EnvName    string
	EnvType    string
	Greeting   string
}

func main() {
	// Get environment variables or set defaults if not present
	appVersion := os.Getenv("APP_VERSION")
	if appVersion == "" {
		appVersion = "pre-alpha"
	}

	envName := os.Getenv("ENV_NAME")
	if envName == "" {
		envName = "Name-Not-Set"
	}

	envType := os.Getenv("ENV_TYPE")
	if envType == "" {
		envType = "local"
	}

	greeting := os.Getenv("GREETING")
	if greeting == "" {
		greeting = "Hello from Go!"
	}

	// Set up static file serving
	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Set up the main page handler
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		data := PageData{
			Title:      "Easier, Better, Faster, Stronger Development with Azure Deployment Environments",
			AppVersion: appVersion,
			EnvName:    envName,
			EnvType:    envType,
			Greeting:   greeting,
		}

		tmpl, err := template.ParseFiles("templates/index.html")
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		err = tmpl.Execute(w, data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	})

	// Start the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server starting on port %s...\n", port)
	fmt.Printf("EnvName: %s, EnvType: %s, Greeting: %s\n", envName, envType, greeting)

	log.Fatal(http.ListenAndServe(":"+port, nil))
}
