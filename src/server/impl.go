package server

import "github.com/tihaya-anon/tx_sys-event-event_producer/src/pb"

type EventProducerServer struct {
	pb.UnimplementedEventProducerServer
}

func NewGrpcHandler() *EventProducerServer {
	return &EventProducerServer{}
}
