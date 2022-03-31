package main

import (
	"encoding/json"
	"fmt"
	"time"

	"example.com/mypowermonitor/kostalinverter"
	"example.com/mypowermonitor/oracleRestClient"
	"example.com/mypowermonitor/power_util"
)

func main() {

	oracleRequest := oracleRestClient.OracleRestJsonRequest{
		Aouthurl:     "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm_dev/oauth/token",
		ClientID:     "Mp5fiHzw0fXVZtKyzb6Vdg..",
		ClientSecret: "koR-XmQzf74S2OpPRq8h0w..",
		AccessUrl:    "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm_dev/rest-v1/inverter/",
		Oauthtoken:   "",
	}

	var j = 0

	for {
		mDate, err := kostalinverter.FetchKostalValue()

		if err != nil {
			fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
		} else {
			j++
			jbytes, err := json.Marshal(mDate)
			jstring := string(jbytes)
			if err != nil {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
			} else {

				fmt.Printf("%s - %d run: %s\n", power_util.GetTimeStr(), j, jstring)

				err = oracleRequest.SaveJsonOracleDB(jstring)

				if err != nil {
					fmt.Printf("%s - oracleRequest.SaveJsonOracleDB: - %s\n", power_util.GetTimeStr(), err)
					fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, oracleRequest.Error_message)
					time.Sleep(time.Duration(120) * time.Second)
				} else {

					if oracleRequest.StatusCode == 400 {
						fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, oracleRequest.Error_message)
					} else if oracleRequest.StatusCode == 401 {
						fmt.Printf("%s - %s\n", power_util.GetTimeStr(), "Request a new token")
						fmt.Printf("%s - %s\n", power_util.GetTimeStr(), oracleRequest.Oauthtoken)
					} else if oracleRequest.StatusCode == 503 {
						fmt.Printf("<<<<%s - %d : %s\n", power_util.GetTimeStr(), j, oracleRequest.Status)
						time.Sleep(time.Duration(120) * time.Second)
					} else {
						fmt.Printf("%s - %d : SaveJsonOracleDB() Status: %s - StatusCode: %d \n", power_util.GetTimeStr(), j, oracleRequest.Status, oracleRequest.StatusCode)
					}
				}
			}
		}

		if mDate.Aktuell == 0 {
			time.Sleep(time.Duration(60) * time.Second)
		} else {
			time.Sleep(time.Duration(10) * time.Second)
		}
	}
}
