package main

import (
	"bytes"
	"fmt"
	"net/http"
	"time"

	"example.com/kostalinverter/kostalinverter"
)

func main() {
	var j = 0
	var urlstr = "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/powermonitor/kostal_inverter/"

	for {
		jDate, err := kostalinverter.FetchKostalDates()
		if err != nil {
			fmt.Println(err)
		} else {
			j++
			fmt.Printf("%d : %s\n", j, jDate)
			resp, err := http.Post(urlstr, "application/json", bytes.NewBuffer([]byte(jDate)))
			//fmt.Println(err)
			if err != nil {
				fmt.Println(err)
			}
			fmt.Printf("%d : %s\n", j, resp.Status)
		}

		time.Sleep(5 * time.Second)
	}
}
