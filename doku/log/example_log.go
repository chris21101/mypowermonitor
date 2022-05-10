package main

import (
	"fmt"
	"log"
	"os"
)

var (
	WarningLogger *log.Logger
	InfoLogger    *log.Logger
	ErrorLogger   *log.Logger
)

func init() {
	//file, err := os.OpenFile("logs.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0666)
	//if err != nil {
	//    log.Fatal(err)
	//}

	InfoLogger = log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	WarningLogger = log.New(os.Stdout, "WARNING: ", log.Ldate|log.Ltime|log.Lshortfile)
	ErrorLogger = log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile)
}

func f1() error {
	name := "F1"
	err := f2()
	return fmt.Errorf("%v: %w", name, err)
}

func f2() error {
	return fmt.Errorf("F2: %s", "Erster Fehler")
}

func main() {
	InfoLogger.Println("Starting the application...")
	InfoLogger.Println("Something noteworthy happened")
	WarningLogger.Println("There is something you should know about")
	ErrorLogger.Println("Something went wrong")
	err := f1()
	InfoLogger.Println(err)
}
