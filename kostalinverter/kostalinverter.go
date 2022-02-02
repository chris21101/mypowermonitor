package kostalinverter

import (
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
)

func FetchKostalValue() (MeasureDate, error) {
	var measure = MeasureDate{}
	r, _ := regexp.Compile("aktuell|Tagesenergie|Gesamtenergie")
	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	req, err := http.NewRequest(http.MethodGet, "http://192.168.178.27", http.NoBody)
	req.Close = true

	if err != nil {
		println(err)
		return measure, err
	}

	req.SetBasicAuth("pvserver", "pvwr")
	t := time.Now()

	formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d",
		t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second())

	res, err := client.Do(req)

	if err != nil {
		fmt.Printf("%s : %s\n", formTimestamp, err)
		return measure, err
	}
	defer res.Body.Close()

	doc, err := goquery.NewDocumentFromReader(res.Body)

	if err != nil {
		println(err)
		return measure, err
	}
	var allValues []string

	j := 0

	doc.Find("tr td").Each(func(i int, s *goquery.Selection) {
		if j != 0 {
			allValues = append(allValues, s.Text())
		}
		j++
	})

	measure.DateTime = formTimestamp
	measure.MeasureType = "KOSTAL"
	for i := 0; i < len(allValues); i++ {
		if r.MatchString(allValues[i]) {
			keyname := strings.ToLower(strings.TrimSpace(strings.TrimLeft(allValues[i], "\r\n")))
			value := strings.TrimSpace(strings.TrimLeft(allValues[i+1], "\r\n"))
			switch keyname {
			case "aktuell":
				if s, err := strconv.ParseFloat(value, 64); err == nil {
					measure.Aktuell = s
				} else {
					measure.Aktuell = 0
				}
			case "tagesenergie":
				if s, err := strconv.ParseFloat(value, 64); err == nil {
					measure.Tagesenergie = s
				} else {
					measure.Tagesenergie = 0
				}
			case "gesamtenergie":
				if s, err := strconv.ParseFloat(value, 64); err == nil {
					measure.Gesamtenergie = s
				} else {
					measure.Tagesenergie = 0
				}
			default:
				println("Wrong columnname found. Not in (aktuell|Tagesenergie|Gesamtenergie) ")
				return measure, errors.New("wrong columnname found with regexp")
			}
		}
	}

	return measure, nil
}
