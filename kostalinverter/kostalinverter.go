package kostalinverter

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
)

func (api *KostalAPI) ReadConfigFromFile() error {
	filename := "config_" + api.Config.ClientName + ".json"
	api.Config.Filename = filename
	fmt.Println("Read " + filename)
	bites, err := ioutil.ReadFile(filename)
	json.Unmarshal(bites, &api.Config)
	if err != nil {
		log.Fatal(err)
	}

	return nil
}

func (api *KostalAPI) SaveToFile() error {
	filename := "config_" + api.Config.ClientName + ".json"

	fmt.Println("Save File " + filename)

	api.Config.Filename = filename
	prettyJSON, err := json.MarshalIndent(api.Config, "", "    ")
	if err != nil {
		log.Fatal("Failed to generate json", err)
	}

	toWrite := []byte(prettyJSON)
	err = ioutil.WriteFile(filename, toWrite, 0644)
	if err != nil {
		log.Fatal("Failed to generate json", err)
	}
	return nil
}

func (api *KostalAPI) CheckOsEnv() error {
	//Read enviroment variable "ClientName"
	api.Config.ClientName = os.Getenv("ClientName")

	if len(api.Config.ClientName) == 0 {
		panic("Not set the Env Variable ClientName")
	}

	return nil
}

func (api *KostalAPI) FetchKostalValue() (MeasureDate, error) {
	var measure = MeasureDate{}
	r, _ := regexp.Compile("aktuell|Tagesenergie|Gesamtenergie")
	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	req, err := http.NewRequest(http.MethodGet, api.Config.KostalServer, http.NoBody)
	req.Close = true

	if err != nil {
		println(err)
		return measure, err
	}

	req.SetBasicAuth(api.Config.KostalUsername, api.Config.KostalPasswd)
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
	measure.ClientName = api.Config.ClientName
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
