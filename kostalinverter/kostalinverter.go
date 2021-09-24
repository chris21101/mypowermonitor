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
	"github.com/go-ping/ping"
)

type measure_date struct {
	Name  string
	Value string
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
	var allMeasure []measure_date
	var measure_map = make(map[string][]measure_date)

	for i := 0; i < len(allValues); i++ {
		if r.MatchString(allValues[i]) {
			keyname := strings.ToLower(strings.TrimSpace(strings.TrimLeft(allValues[i], "\r\n")))
			valuename := strings.TrimSpace(strings.TrimLeft(allValues[i+1], "\r\n"))

			measure.Name = keyname
			measure.Value = valuename

			allMeasure = append(allMeasure, measure)
		}
	}

	measure_map[formTimestamp] = allMeasure
	b, err := json.Marshal(measure_map)

	if err != nil {
		log.Fatal(err)

	}
	return string(b), nil
}

func pinging() {
	pinger, err := ping.NewPinger("192.168.50.238")
	timeout := time.Second * 10
	interval := time.Second
	if err != nil {
		fmt.Println(err)

	} else {
		pinger.SetPrivileged(true)
		pinger.Interval = interval
		pinger.Timeout = timeout
		pinger.Count = 1
		err = pinger.Run() // Blocks until finished.
		if err != nil {
			fmt.Println(err)
		} else {
			stats := pinger.Statistics() // get send/receive/duplicate/rtt stats
			fmt.Println(stats)
		}
	}
}

func main() {
	var j = 0
	for {
		jDate, err := fetchKostalDates()
		if err != nil {
			fmt.Println(err)
			pinging()
		}

		j++
		fmt.Printf("%d : %s\n", j, jDate)
		time.Sleep(2 * time.Second)
		pinging()
	}
}
