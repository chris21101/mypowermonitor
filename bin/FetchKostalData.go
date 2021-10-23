package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"example.com/kostalinverter/kostalinverter"
	"example.com/kostalinverter/oracleRestClient"
	"example.com/kostalinverter/power_util"
)

func main() {
	newTokenRequest := oracleRestClient.OracleTokenRequest{
		Aouthurl:     "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/oauth/token",
		ClientID:     "HOG9HK859p3I4Uk5IKbF4Q..",
		ClientSecret: "iNCuRgR0qmd-0poma_O2ew.."}

	newOracleRequest := oracleRestClient.OraclePostRequest{
		AccessUrl:  "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/rest-v1/inverter/",
		Oauthtoken: "",
	}

	if newOracleRequest.Oauthtoken == "" {
		newtoken, err := oracleRestClient.GetOracleDBtoken(newTokenRequest)
		if err != nil {
			log.Fatal(err)
		}
		newOracleRequest.Oauthtoken = newtoken
	}

	fmt.Printf("%s - %s\n", power_util.GetTimeStr(), newOracleRequest.Oauthtoken)

	var j = 0
	//var counter0 int = 0

	for {
		mDate, err := kostalinverter.FetchKostalValue()

		if err != nil {
			fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
		} else {
			j++
			jstring, err := json.Marshal(mDate)

			if err != nil {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
			}

			fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, jstring)

			//Save the jstring over restfull service in the table inverter_rest
			if newOracleRequest.Oauthtoken == "" {
				newtoken, err := oracleRestClient.GetOracleDBtoken(newTokenRequest)
				if err != nil {
					log.Fatal(err)
				}
				newOracleRequest.Oauthtoken = newtoken
			}

			client := &http.Client{
				Timeout: 10 * time.Second,
			}

			req, err := http.NewRequest(http.MethodPost, newOracleRequest.AccessUrl, bytes.NewBuffer([]byte(jstring)))
			if err != nil {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
			}
			req.Close = true
			req.Header.Set("Authorization", newOracleRequest.Oauthtoken)

			resp, err := client.Do(req)

			if err != nil {
				fmt.Println(err)
			}
			fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, resp.Status)

			if resp.StatusCode == 401 {
				newtoken, err := oracleRestClient.GetOracleDBtoken(newTokenRequest)
				if err != nil {
					log.Fatal(err)
				}
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), newtoken)
				newOracleRequest.Oauthtoken = newtoken
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), newOracleRequest.Oauthtoken)
			}

		}

		if mDate.Aktuell == 0 {
			time.Sleep(time.Duration(60) * time.Second)
		} else {
			time.Sleep(time.Duration(2) * time.Second)
		}
	}
}
