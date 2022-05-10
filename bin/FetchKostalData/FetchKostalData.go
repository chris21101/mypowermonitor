package main

import (
	"encoding/json"
	"os"
	"time"

	"example.com/mypowermonitor/kostalinverter"
	"example.com/mypowermonitor/oracleRestClient"
	"example.com/mypowermonitor/power_util"
)

func main() {
	var kostalapi kostalinverter.KostalAPI
	var oracleRequest oracleRestClient.OracleRestJsonRequest
	/*
		oracleRequest := oracleRestClient.OracleRestJsonRequest{
			Aouthurl:     "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/oauth/token",
			ClientID:     "qy-Hl2w-dZB7bcrAltc5cQ..",
			ClientSecret: "a0LeMyE72CVc3VhZt3aRCg..",
			AccessUrl:    "https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/rest-v1/inverter/",
			Oauthtoken:   "",
		}
	*/
	_ = kostalapi.CheckOsEnv()
	logger := power_util.NewLoggerConfig(os.Getenv("LogLevel"), "CONSOLE", "")
	kostalapi.Set_LoggerConfig(logger)
	oracleRequest.Set_LoggerConfig(logger)
	sugarLogger := logger.ZapLogger
	defer sugarLogger.Sync()
	sugarLogger.Infof("Start FetchKostalData <%s> ", os.Getenv("LogLevel"))

	_ = kostalapi.ReadConfigFromFile()

	oracleRequest.AccessUrl = kostalapi.Config.OracleDB.AccessUrl
	oracleRequest.Aouthurl = kostalapi.Config.OracleDB.Aouthurl
	oracleRequest.ClientID = kostalapi.Config.OracleDB.ClientID
	oracleRequest.ClientSecret = kostalapi.Config.OracleDB.ClientSecret

	var j = 0

	for {
		mDate, err := kostalapi.FetchKostalValue()

		if err != nil {
			sugarLogger.Errorf("%s", err)
		} else {
			j++
			jbytes, err := json.Marshal(mDate)
			jstring := string(jbytes)
			if err != nil {
				sugarLogger.Errorf("%s", err)
			} else {

				sugarLogger.Debugf("%d run: %s", j, jstring)

				err = oracleRequest.SaveJsonOracleDB(jstring)

				if err != nil {
					sugarLogger.Errorf("oracleRequest.SaveJsonOracleDB: - %s", err)
					sugarLogger.Errorf("%d : %s", j, oracleRequest.Error_message)
					time.Sleep(time.Duration(120) * time.Second)
				} else {

					if oracleRequest.StatusCode == 400 {
						sugarLogger.Debugf("%d : %s", j, oracleRequest.Error_message)
					} else if oracleRequest.StatusCode == 401 {
						sugarLogger.Debugf("%s\n", "Request a new token")
						sugarLogger.Debugf("%s\n", oracleRequest.Oauthtoken)
					} else if oracleRequest.StatusCode == 503 {
						sugarLogger.Debugf("%d : %s\n", j, oracleRequest.Status)
						time.Sleep(time.Duration(120) * time.Second)
					} else {
						sugarLogger.Infof("%d : SaveJsonOracleDB() Status: %s - StatusCode: %d", j, oracleRequest.Status, oracleRequest.StatusCode)
					}
				}
			}
		}

		if mDate.Aktuell == 0 {
			time.Sleep(time.Duration(60) * time.Second)
		} else {
			sleepTime := kostalapi.Config.SleepTime
			time.Sleep(time.Duration(sleepTime) * time.Second)
		}
	}
}
