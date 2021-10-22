package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"example.com/kostalinverter/kostalinverter"
	"example.com/kostalinverter/power_util"
)

func main() {
	var j = 0
	var counter0 int = 0
	for {
		mDate, err := kostalinverter.FetchKostalValue()

		if err != nil {
			fmt.Println(err)
		} else {
			j++
			jstring, err := json.Marshal(mDate)

			if err != nil {
				println(err)
			}

			fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, jstring)
			if mDate.Aktuell >= 0 && counter0 <= 10 {
				if mDate.Aktuell == 0 && mDate.Tagesenergie > 0 {
					counter0 = counter0 + 1
				} else {
					counter0 = 0
				}
				//Save the jstring over restfull service in the table inverter_rest
				var urlstr = "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/rest-v1/inverter/"
				client := &http.Client{
					Timeout: 10 * time.Second,
				}

				resp, err := client.Post(urlstr, "application/json", bytes.NewBuffer([]byte(jstring)))
				if err != nil {
					fmt.Println(err)
				}
				fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, resp.Status)
			} else {
				fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, "Not saved because actual_energy = 0 and daily_energie > 0")
			}
		}

		if mDate.Aktuell == 0 {
			time.Sleep(time.Duration(60) * time.Second)
		} else {
			time.Sleep(time.Duration(2) * time.Second)
		}
	}
}
