package constant

import (
	"os"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/tihaya-anon/tx_sys-event-event_producer/src/constant/app"
)

var APP_ENV string

func init() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr}).With().Caller().Logger()
	app.Init()
	APP_ENV = app.APP_ENV
}
