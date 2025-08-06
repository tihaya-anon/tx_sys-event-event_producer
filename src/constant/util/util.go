package util

import "os"

func GetEnv(key string, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

func MustGetEnv(key string) string {
	value := GetEnv(key, "")
	if value == "" {
		panic("env " + key + " is not set")
	}
	return value
}
