package app

import (
	"slices"

	"github.com/rs/zerolog/log"
	"github.com/tihaya-anon/tx_sys-event-event_producer/src/constant/util"
)

const (
	APP_ENV_NAME    = "APP_ENV"
	APP_ENV_DEFAULT = "dev"
)

var EnvList = []string{"dev", "prod", "test"}

var APP_ENV string

func Init() {
	APP_ENV = util.GetEnv(APP_ENV_NAME, APP_ENV_DEFAULT)
	if slices.Contains(EnvList, APP_ENV) {
		log.Info().Msgf("APP_ENV `%s`", APP_ENV)
		return
	}
	log.Info().Msgf("Invalid APP_ENV `%s`, supported values are %v, set to default `%s`", APP_ENV, EnvList, APP_ENV_DEFAULT)
	APP_ENV = APP_ENV_DEFAULT
}
