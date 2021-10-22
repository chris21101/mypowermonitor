package power_util

import (
	"fmt"
	"time"
)

func GetTimeStr() string {
	t := time.Now()

	formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d%d",
		t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second(), t.Nanosecond())
	return formTimestamp
}
