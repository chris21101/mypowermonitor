package kostalinverter

type KostalConfig struct {
	ClientName     string `json:"ClientName"`
	Filename       string `json:"Filename"`
	ConsumerKey    string `json:"ConsumerKey"`
	ConsumerSecret string `json:"ConsumerSecret"`
	KostalUsername string `json:"KostalUsername"`
	KostalPasswd   string `json:"KostalPasswd"`
	KostalServer   string `json:"KostalServer"`
	OracleDB       KostalOracleDB
}
type KostalOracleDB struct {
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

type KostalAPI struct {
	Config KostalConfig
}
