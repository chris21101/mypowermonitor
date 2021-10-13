package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
)

type measure_date struct {
	DateTime      string
	Aktuell       string
	Tagesenergie  string
	Gesamtenergie string
}

func fetchKostalDates() (string, error) {
	r, _ := regexp.Compile("aktuell|Tagesenergie|Gesamtenergie")
	client := http.Client{Timeout: 10 * time.Second}

	req, err := http.NewRequest(http.MethodGet, "http://192.168.50.238", http.NoBody)
	if err != nil {
		println(err)
		return "", err
	}

	req.SetBasicAuth("pvserver", "pvwr")
	t := time.Now()

	formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d",
		t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second())

	res, err := client.Do(req)
	if err != nil {
		fmt.Printf("%s : %s\n", formTimestamp, err)
		return "", err
	}
	defer res.Body.Close()

	doc, err := goquery.NewDocumentFromReader(res.Body)

	if err != nil {
		println(err)
		return "", err
	}
	var allValues []string

	j := 0

	doc.Find("tr td").Each(func(i int, s *goquery.Selection) {
		if j != 0 {
			allValues = append(allValues, s.Text())
		}
		j++
	})

	var measure = measure_date{}

	measure.DateTime = formTimestamp
	for i := 0; i < len(allValues); i++ {
		if r.MatchString(allValues[i]) {
			keyname := strings.ToLower(strings.TrimSpace(strings.TrimLeft(allValues[i], "\r\n")))
			valuename := strings.TrimSpace(strings.TrimLeft(allValues[i+1], "\r\n"))
			switch keyname {
			case "aktuell":
				measure.Aktuell = valuename
			case "tagesenergie":
				measure.Tagesenergie = valuename
			case "gesamtenergie":
				measure.Gesamtenergie = valuename
			}
		}
	}

	b, err := json.Marshal(measure)

	if err != nil {
		log.Fatal(err)

	}
	return string(b), nil
}

func main() {
	var j = 0
	for {
		jDate, err := fetchKostalDates()
		if err != nil {
			fmt.Println(err)
		}

		j++
		fmt.Printf("%d : %s\n", j, jDate)
		time.Sleep(2 * time.Second)
	}
}
