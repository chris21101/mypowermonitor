package kostalinverter

type MeasureDate struct {
	DateTime      string  `json:"measure_time"`
	MeasureType   string  `json:"inverter_type"`
	Aktuell       float64 `json:"actual_energie"`
	Tagesenergie  float64 `json:"daily_energie"`
	Gesamtenergie float64 `json:"total_energie"`
}
