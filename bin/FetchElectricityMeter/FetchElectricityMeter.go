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
	var disapi discovergy.DiscovergyAPI
	var oracleRequest oracleRestClient.OracleRestJsonRequest
	//Needs Env "ClientName, DiscovergyEmail and DiscovergyPasswd"
	_ = disapi.CheckOsEnv()
	logger := power_util.NewLoggerConfig(os.Getenv("LogLevel"), "CONSOLE", "")
	disapi.Set_LoggerConfig(logger)
	oracleRequest.Set_LoggerConfig(logger)
	sugarLogger := logger.ZapLogger
	defer sugarLogger.Sync()
	sugarLogger.Infof("Start %s <%s> ", os.Getenv("ClientName"), os.Getenv("LogLevel"))

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

	oracleRequest.AccessUrl = disapi.Config.OracleDB.AccessUrl
	oracleRequest.Aouthurl = disapi.Config.OracleDB.Aouthurl
	oracleRequest.ClientID = disapi.Config.OracleDB.ClientID
	oracleRequest.ClientSecret = disapi.Config.OracleDB.ClientSecret

	// Programm needs a ConsumerKey and ConsumerSecret

	err := disapi.ClientRegistration()

	if err != nil {
		sugarLogger.Errorf("Failed ClientRegistration: %s \n", err)
		os.Exit(3)
	}

	// Every 24h we need a new token ???
	err = disapi.NewToken()
	if err != nil {
		sugarLogger.Errorf("Failed NewToken: %s \n", err)
		os.Exit(3)
	}

	var j = 0

	for {
		var measures discovergy.DiscovergyReads
		var disresults discovergy.DiscovergyResult
		disresults.ClientName = disapi.Config.ClientName
		sugarLogger.Infof("%s", "Start new reading: "+disapi.Config.ClientName)

		result, httpStatusCode, err := disapi.GetLastRead()
		strHttpStatusCode := strconv.Itoa(httpStatusCode)
		sugarLogger.Debugf("%s - %s", power_util.GetTimeStr(), "HTTP StatusCode = "+strHttpStatusCode)
		if err != nil {
			sugarLogger.Errorf("%s - %s", power_util.GetTimeStr(), err)
			time.Sleep(time.Duration(60) * time.Second)
		} else if httpStatusCode == 401 {
			err := disapi.NewToken()
			if err != nil {
				sugarLogger.Errorf("%s - %s", power_util.GetTimeStr(), " ERROR: NewToken()")
				sugarLogger.Errorf("%s - %s", power_util.GetTimeStr(), err)
				time.Sleep(time.Duration(300) * time.Second)
			}
			continue
		} else if httpStatusCode == 400 {
			err := disapi.ClientRegistration()

			if err != nil {
				sugarLogger.Errorf("Failed ClientRegistration: %s ", err)
				os.Exit(3)
			}
		} else {
			//Expected output:
			//{"time":1636152869126,"values":{"energyOut":119411587467000,"energy":138376348839000,"power":344460}}
			//fmt.Println(bodyString)
			Data := []byte(result)

			err := json.Unmarshal(Data, &measures)

			if err != nil {
				sugarLogger.Errorf("ERROR: %v", err)
			}
			tUnix := measures.MeasureTime / int64(time.Microsecond)
			t := time.Unix(tUnix, 0)

			formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d",
				t.Year(), t.Month(), t.Day(),
				t.Hour(), t.Minute(), t.Second())

			sugarLogger.Debugf("%s - Datum: %s", power_util.GetTimeStr(), formTimestamp)
			disresults.MeasureTime = formTimestamp
			disresults.Energy = measures.Values.Energy
			disresults.EnergyOut = measures.Values.EnergyOut
			disresults.Power = measures.Values.Power

			jbytes, _ := json.Marshal(disresults)
			jstring := string(jbytes)
			//fmt.Printf("%s - %s\n", power_util.GetTimeStr(), jstring)
			sugarLogger.Debugf("%s", jstring)
			//++++++++++++++++++++++++++++++++++++++ New Save to Oracle ++++++++++++++++++++
			err = oracleRequest.SaveJsonOracleDB(jstring)
			//fmt.Printf("%v\n", oracleRequest)
			j++
			if err != nil {
				sugarLogger.Errorf("%s - Error: SaveJsonOracleDB() - %s", power_util.GetTimeStr(), err)
			} else {

				if oracleRequest.StatusCode == 400 {
					sugarLogger.Errorf("%d :!! %s", j, oracleRequest.Error_message)
				} else if oracleRequest.StatusCode == 401 {
					sugarLogger.Errorf("%s", "Request a new token")
					sugarLogger.Errorf("%s", oracleRequest.Oauthtoken)
					continue
				} else if oracleRequest.StatusCode == 503 {
					sugarLogger.Errorf("No Oracle Service: %s", oracleRequest.Status)
					time.Sleep(time.Duration(120) * time.Second)
					continue
				} else {
					sugarLogger.Infof("%d : SaveJsonOracleDB() Status: %s - StatusCode: %d", j, oracleRequest.Status, oracleRequest.StatusCode)
				}
			}
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			sugarLogger.Debugf("%d : Sleep %d Seconds", j, disapi.Config.SleepTime)
			time.Sleep(time.Duration(disapi.Config.SleepTime) * time.Second)
		}

	}
}
