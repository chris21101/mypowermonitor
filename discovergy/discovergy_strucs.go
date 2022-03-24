package discovergy

type DiscovergyConfig struct {
	ClientName            string `json:"ClientName"`
	Filename              string `json:"Filename"`
	BaseUrl               string `json:"BaseUrl"`
	MeterId               string `json:"MeterId"`
	ReadingFealds         string `json:"ReadingFealds"`
	ClientRegistrationUrl string `json:"ClientRegistrationUrl"`
	RequestTokenUrl       string `json:"RequestTokenUrl"`
	AuthorizeURL          string `json:"AuthorizeURL"`
	AccessTokenURL        string `json:"AccessTokenURL"`
	LastReadUrl           string `json:"LastReadUrl"`
	ConsumerKey           string `json:"ConsumerKey"`
	ConsumerSecret        string `json:"ConsumerSecret"`
}

type ClientRegResponse struct {
	ConsumerKey    string `json:"key"`
	ConsumerSecret string `json:"secret"`
	Owner          string `json:"owner"`
}

type DiscovergyAPI struct {
	Config              DiscovergyConfig
	Oauth_RequestToken  string `json:"Oauth_RequestToken"`
	Oauth_RequestSecret string `json:"Oauth_RequestSecret"`
	Oauth_AccessToken   string `json:"Oauth_AccessToken"`
	Oauth_AccessSecret  string `json:"Oauth_AccessSecret"`
	Oauth_Verifier      string `json:"Oauth_Verifier"`
}

type DiscovergyEnergy struct {
	EnergyOut int64 `json:"energyOut"`
	Energy    int64 `json:"energy"`
	Power     int64 `json:"power"`
}

type DiscovergyReads struct {
	MeasureTime int64 `json:"time"`
	Values      DiscovergyEnergy
}

type DiscovergyResult struct {
	MeasureTime string `json:"measure_time"`
	EnergyOut   int64  `json:"energyout"`
	Energy      int64  `json:"energy"`
	Power       int64  `json:"power"`
}
