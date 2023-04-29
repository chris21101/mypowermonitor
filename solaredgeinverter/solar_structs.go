package solaredgeinverter

type SolarConfig struct {
	ClientName        string `json:"ClientName"`
	Filename          string `json:"Filename"`
	ConsumerKey       string `json:"ConsumerKey"`
	ConsumerSecret    string `json:"ConsumerSecret"`
	Hostname          string `json:"Hostname"`
	Port              int    `json:"Port"`
	ConnectionTimeout int64  `json:"ConnectionTimeout"`
	OracleDB          SolarOracleDB
}
type SolarOracleDB struct {
	Aouthurl     string `json:"Aouthurl"`
	ClientID     string `json:"ClientID"`
	ClientSecret string `json:"ClientSecret"`
	AccessUrl    string `json:"AccessUrl"`
}

type MeasureDate struct {
	DateTime      string  `json:"measure_time"`
	ClientName    string  `json:"clientname"`
	Aktuell       float64 `json:"actual_energie"`
	Tagesenergie  float64 `json:"daily_energie"`
	Gesamtenergie float64 `json:"total_energie"`
}

type SolarAPI struct {
	Config SolarConfig
}

type SolarResult struct {
	Time         int64   `json:"time"`
	AC_Energy_WH float64 `json:"AC_Energy_WH"`
	AC_Power     float64 `json:"AC_Power"`
}

/*
"MeterId": "7B00E992",
"AC_Voltage_L1_N": 233.4,
"AC_Voltage_L2_N": 234.4,
"AC_Voltage_L3_N": 232.9,
"AC_Power": 0,
"AC_Frequency": 50.01,
"AC_VA": 0,
"AC_VAR": 0,
"AC_PF": 0,
"AC_Energy_WH": 4724,
"DC_Current": 0,
"DC_Voltage": 0.8,
"DC_Power": 0,
"Temp_Sink": 20.06,
"InverterStatus": 2,
"time": 1682714572943
*/
