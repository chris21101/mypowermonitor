package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"time"

	"example.com/mypowermonitor/discovergy"
	"example.com/mypowermonitor/oracleRestClient"
	"example.com/mypowermonitor/power_util"
)

func main() {
	fmt.Println("Start TestDiscovergyAPI")
	var disapi discovergy.DiscovergyAPI

	//Needs Env "ClientName, DiscovergyEmail and DiscovergyPasswd"
	_ = disapi.CheckOsEnv()

	/*
		Requires the following variables
		On Powershell:
		*  $Env:ClientName = "discovergy_ws"
		Discovergy Account:
		*  $Env:DiscovergyEmail = "fffffffff@mail.de"
		*  $Env:DiscovergyPasswd = "********"
		Bash use export
		Needs config file config_<ClientName>.json in the root directory
		https://api.discovergy.com/docs/#/OAuth1
		Example config_discovergy_ws.json
		{
		"ClientName": "discovergy_ws",
		"Filename": "config_discovergy_ws.json",
		"BaseUrl": "https://api.discovergy.com",
		"MeterId": "345598f062f64a5196b556d5d2a50746",
		"ReadingFealds": "energy,energyOut,power",
		"ClientRegistrationUrl": "/public/v1/oauth1/consumer_token",
		"RequestTokenUrl": "/public/v1/oauth1/request_token",
		"AuthorizeURL": "/public/v1/oauth1/authorize",
		"AccessTokenURL": "/public/v1/oauth1/access_token",
		"LastReadUrl": "/public/v1/last_reading",
		"ConsumerKey": "",
		"ConsumerSecret": ""
		}
	*/
	_ = disapi.ReadConfigFromFile()

	// Programm needs a ConsumerKey and ConsumerSecret
	if len(disapi.Config.ConsumerKey) == 0 || len(disapi.Config.ConsumerSecret) == 0 {
		err := disapi.ClientRegistration()

		if err != nil {
			fmt.Printf("Failed ClientRegistration: %s \n", err)
			os.Exit(3)
		}
	} else {
		fmt.Println("Client is registered")
	}

	// Every 24h we need a new token ???
	err := disapi.NewToken()
	if err != nil {
		fmt.Printf("Failed NewToken: %s \n", err)
		os.Exit(3)
	}

	var j = 0

	for {
		var measures discovergy.DiscovergyReads
		var disresults discovergy.DiscovergyResult
		fmt.Printf("%s - %s\n", power_util.GetTimeStr(), "Start new reading")
		result, httpStatusCode, err := disapi.GetLastRead()
		strHttpStatusCode := strconv.Itoa(httpStatusCode)
		fmt.Printf("%s - %s\n", power_util.GetTimeStr(), "HTTP StatusCode = "+strHttpStatusCode)
		if err != nil {
			fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
			time.Sleep(time.Duration(60) * time.Second)
		} else {
			//Expected output:
			//{"time":1636152869126,"values":{"energyOut":119411587467000,"energy":138376348839000,"power":344460}}
			//fmt.Println(bodyString)
			Data := []byte(result)

			err := json.Unmarshal(Data, &measures)

			if err != nil {
				fmt.Println(err)
			}
			tUnix := measures.MeasureTime / int64(time.Microsecond)
			t := time.Unix(tUnix, 0)

			formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d",
				t.Year(), t.Month(), t.Day(),
				t.Hour(), t.Minute(), t.Second())

			fmt.Printf("%s - Datum: %s\n", power_util.GetTimeStr(), formTimestamp)
			disresults.MeasureTime = formTimestamp
			disresults.Energy = measures.Values.Energy
			disresults.EnergyOut = measures.Values.EnergyOut
			disresults.Power = measures.Values.Power

			jbytes, _ := json.Marshal(disresults)
			jstring := string(jbytes)
			fmt.Printf("%s - %s\n", power_util.GetTimeStr(), jstring)

			//++++++++++++++++++++++++++++++++++++++ New Save to Oracle ++++++++++++++++++++
			oracleRequest := oracleRestClient.OracleRestJsonRequest{
				Aouthurl:     "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/oauth/token",
				ClientID:     "eNC0tHpiENRcRIy6m1Py3w..",
				ClientSecret: "rswBxuI877CbWEVyWua9Wg..",
				AccessUrl:    "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/rest-v1/discovergy/",
				Oauthtoken:   "",
			}

			err = oracleRequest.SaveJsonOracleDB(jstring)
			j++
			if err != nil {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), err)
			}

			if oracleRequest.StatusCode == 400 {
				fmt.Printf("%s - %d : %s\n", power_util.GetTimeStr(), j, oracleRequest.Error_message)
			} else if oracleRequest.StatusCode == 401 {
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), "Request a new token")
				fmt.Printf("%s - %s\n", power_util.GetTimeStr(), oracleRequest.Oauthtoken)
			} else {
				fmt.Printf("%s - %d : Save Oracle %s\n", power_util.GetTimeStr(), j, oracleRequest.Status)
			}

			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			time.Sleep(time.Duration(10) * time.Second)
		}

	}
}
