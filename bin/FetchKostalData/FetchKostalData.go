package main

import (
	"encoding/json"
	"fmt"
	"time"

	"example.com/kostalinverter/kostalinverter"
	"example.com/kostalinverter/oracleRestClient"
	"example.com/kostalinverter/power_util"
)

func main() {

	oracleRequest := oracleRestClient.OracleRestJsonRequest{
		Aouthurl:     "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/oauth/token",
		ClientID:     "eNC0tHpiENRcRIy6m1Py3w..",
		ClientSecret: "rswBxuI877CbWEVyWua9Wg..",
		AccessUrl:    "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/rest-v1/inverter/",
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
			}

			fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, jstring)

			err = oracleRequest.SaveJsonOracleDB(jstring)

			if err != nil {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
			}

			if oracleRequest.StatusCode == 400 {
				fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, oracleRequest.Error_message)
			} else if oracleRequest.StatusCode == 401 {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), "Request a new token")
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), oracleRequest.Oauthtoken)
			} else {
				fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, oracleRequest.Status)
			}
		}

		if mDate.Aktuell == 0 {
			time.Sleep(time.Duration(60) * time.Second)
		} else {
			time.Sleep(time.Duration(2) * time.Second)
		}
	}
}
