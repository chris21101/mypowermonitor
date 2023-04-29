package solaredgeinverter

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/signal"
	"time"

	"example.com/mypowermonitor/power_util"

	mapping "github.com/stefannilsson/solaredgedc/datamapping"
	modbus "github.com/stefannilsson/solaredgedc/poller"
)

var loggerConfig *power_util.LoggerConfig

const (
	GRACEFUL_SHUTDOWN_TIMEOUT_MS = 2000 // ms to let modbus poller / mqtt publisher to gracefully disconnect.
	DELAY_UNSUCCESSFUL_POLLS_MS  = 1000 // ms to be delayed between attempts if no successful modbus reads finished
)

func (api *SolarAPI) Set_LoggerConfig(p_logger *power_util.LoggerConfig) {
	loggerConfig = p_logger
}

func (api *SolarAPI) ReadConfigFromFile() error {
	filename := "config_" + api.Config.ClientName + ".json"
	api.Config.Filename = filename
	loggerConfig.ZapLogger.Debugf("Read File: %s", filename)
	//fmt.Println("Read " + filename)
	bites, err := ioutil.ReadFile(filename)
	json.Unmarshal(bites, &api.Config)
	if err != nil {
		loggerConfig.ZapLogger.Fatal(err)
	}

	return nil
}

func (api *SolarAPI) SaveToFile() error {
	filename := "config_" + api.Config.ClientName + ".json"

	loggerConfig.ZapLogger.Info("Save File " + filename)

	api.Config.Filename = filename
	prettyJSON, err := json.MarshalIndent(api.Config, "", "    ")
	if err != nil {
		loggerConfig.ZapLogger.Fatal("Failed to generate json", err)
	}

	toWrite := []byte(prettyJSON)
	err = ioutil.WriteFile(filename, toWrite, 0644)
	if err != nil {
		loggerConfig.ZapLogger.Fatal("Failed to generate json", err)
	}
	return nil
}

func (api *SolarAPI) CheckOsEnv() error {
	//Read enviroment variable "ClientName"
	api.Config.ClientName = os.Getenv("ClientName")

	if len(api.Config.ClientName) == 0 {
		panic("Not set the Env Variable ClientName")
	}

	return nil
}

func (api *SolarAPI) FetchSolarValue(modbusClient *modbus.ModbusClient) (MeasureDate, error) {
	var measure = MeasureDate{}

	HandleSigInt(modbusClient)

	registerValues := modbus.PollRegisters(modbusClient)
	// TODO: Implement check and indicator from PollRegister(...) if total read time was more than X amount of ms. Could be an issue if some registers took a very long time to read.

	// if no successfully register values read, let's sleep for a second and try again.
	if len(*registerValues) == 0 {
		time.Sleep(DELAY_UNSUCCESSFUL_POLLS_MS * time.Millisecond)
	}

	// key/value map
	// key : Modbus/SunSpec Register name
	// value : Scaled (in case of a numeric data type). Possible data types: {int16, uint16, uint32, string}
	// scaledValues := modbuspoller.ModbusRegistries{}
	parsedValues := mapping.ParseValues(registerValues)
	//fmt.Printf("%V", parsedValues)
	// Populate JSON with successfully read registers mapped to standard model.
	json_s := mapping.SerializeToJson(parsedValues)
	var result SolarResult
	json.Unmarshal([]byte(json_s), &result)

	tUnix := result.Time / int64(time.Microsecond)
	t := time.Unix(tUnix, 0)

	formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d",
		t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second())
	/*
		fmt.Println("******************************************************")
		fmt.Printf("Uhrzeit: %s\n", formTimestamp)
		fmt.Printf("AC_Energy_WH: %d\n", result.AC_Energy_WH)
		fmt.Printf("AC_Power: %d\n", result.AC_Power)
		fmt.Println("******************************************************")
		//fmt.Printf("run: %V", &result)
	*/

	measure.ClientName = api.Config.ClientName
	measure.DateTime = formTimestamp
	// -999 There is no summed up value for Daily
	measure.Tagesenergie = -999
	measure.Aktuell = result.AC_Power
	//SolarEdge gives the value in wH and we need KwH
	measure.Gesamtenergie = result.AC_Energy_WH / 1000
	return measure, nil
}

func HandleSigInt(modbusClient *modbus.ModbusClient) {
	// give modbus & mqtt client some time to gracefully disconnect in case of CTRL+C
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		<-c
		// sig is a ^C, handle it
		loggerConfig.ZapLogger.Fatal("Shutting down... Exiting in %v ms.", GRACEFUL_SHUTDOWN_TIMEOUT_MS)

		// Disconnect Modbus
		modbusClient.TCPClientHandler.Close()

		// Let's give clients some time to
		time.Sleep(GRACEFUL_SHUTDOWN_TIMEOUT_MS * time.Millisecond)

		os.Exit(-1)
	}()
}
