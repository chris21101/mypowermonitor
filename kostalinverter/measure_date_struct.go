package kostalinverter

type MeasureDate struct {
	DateTime      string  `json:"datetime"`
	MeasureType   string  `json:"measuretype"`
	Aktuell       float64 `json:"actualenergie"`
	Tagesenergie  float64 `json:"dailyenergie"`
	Gesamtenergie float64 `json:"totalenergie"`
}
