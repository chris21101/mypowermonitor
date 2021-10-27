package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
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
		ClientID:     "eNC0tHpiENRcRIy6m1Py3w..",
		ClientSecret: "rswBxuI877CbWEVyWua9Wg.."}

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
			req.Header.Set("Content-Type", "application/json")
			resp, err := client.Do(req)
			if err != nil {
				fmt.Println(err)
				resp.Body.Close()
			} else {

				body, _ := ioutil.ReadAll(resp.Body)
				resp.Body.Close()

				if err != nil {
					fmt.Println(err)
					fmt.Println(body)
				}
			}
			fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, resp.Status)
			//Error handling output from the database status code 400 and ERROR_MESSAGE or 401 unautherized
			if resp.StatusCode == 400 {
				fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, resp.Header.Get("ERROR_MESSAGE"))
			} else if resp.StatusCode == 401 {
				//We need a new token now
				newtoken, err := oracleRestClient.GetOracleDBtoken(newTokenRequest)
				if err != nil {
					log.Fatal(err)
				}
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
