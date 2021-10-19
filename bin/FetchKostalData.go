package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"example.com/kostalinverter/kostalinverter"
)

func main() {
	var j = 0

	for {
		/*
			type MeasureDate struct {
				DateTime      string  `json:"datetime"`
				MeasureType   string  `json:"measuretype"`
				Aktuell       float64 `json:"actualenergie"`
				Tagesenergie  float64 `json:"dailyenergie"`
				Gesamtenergie float64 `json:"totalenergie"`
			}
		*/
		mDate, err := kostalinverter.FetchKostalDates()

		if err != nil {
			fmt.Println(err)
		} else {
			j++
			jstring, err := json.Marshal(mDate)

			if err != nil {
				println(err)
			}

			fmt.Printf("%d : %s\n", j, jstring)

			//Save the jstring over restfull service in the table kostal_inverter_rest
			var urlstr = "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/powermonitor/kostal_inverter/"
			resp, err := http.Post(urlstr, "application/json", bytes.NewBuffer([]byte(jstring)))
			if err != nil {
				fmt.Println(err)
			}

			fmt.Printf("%d : %s\n", j, resp.Status)
		}

		if mDate.Aktuell == 0 {
			time.Sleep(60 * time.Second)
		} else {
			time.Sleep(5 * time.Second)
		}
	}
}
