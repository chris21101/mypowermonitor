package power_util

import (
	"fmt"
	"os"
	"strings"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

const (
	DEBUG = "DEBUG"
	INFO  = "INFO"
	ERROR = "ERROR"
)

type LoggerConfig struct {
	LogLevel    zapcore.Level       // DEBUG, INFO, ERROR
	Encoder     zapcore.Encoder     // CONSOLE,JSON
	WriteSyncer zapcore.WriteSyncer // ./test.log | ""
	ZapLogger   *zap.SugaredLogger
}

func NewLoggerConfig(LogLevel string, EncoderType string, FileName string) *LoggerConfig {
	logger := new(LoggerConfig)
	logger.LogLevel = getLogLevel(LogLevel)
	writeSyncer := getLogWriter(FileName)
	encoder := getEncoder(EncoderType)
	core := zapcore.NewCore(encoder, writeSyncer, logger.LogLevel)

	log := zap.New(core)
	logger.ZapLogger = log.Sugar()
	return logger
}

func (logC *LoggerConfig) GetLogger() *zap.SugaredLogger {
	return logC.ZapLogger
}

func getLogLevel(loglevel string) zapcore.Level {
	if strings.ToUpper(loglevel) == ERROR {
		return zapcore.ErrorLevel
	} else if strings.ToUpper(loglevel) == DEBUG {
		return zapcore.DebugLevel
	} else {
		return zapcore.InfoLevel
	}
}

func getEncoder(encodertype string) zapcore.Encoder {

	if strings.ToUpper(encodertype) == "JSON" {
		return zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())
	} else {
		encoderConfig := zap.NewProductionEncoderConfig()
		// Time function can be customized
		encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
		encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
		return zapcore.NewConsoleEncoder(encoderConfig)
	}
}

func getLogWriter(filename string) zapcore.WriteSyncer {
	//file, _ := os.Create("./test.log")
	if filename == "" {
		return zapcore.AddSync(os.Stdout)
	} else {
		file, _ := os.Create("./" + filename)
		return zapcore.AddSync(file)
	}
}

func GetTimeStr() string {
	t := time.Now()

	formTimestamp := fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d%d",
		t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second(), t.Nanosecond())
	return formTimestamp
}
