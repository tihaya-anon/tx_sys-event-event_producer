package server

import (
	"context"

	"github.com/tihaya-anon/tx_sys-event-event_producer/src/pb"
)

type EventProducerServer struct {
	pb.UnimplementedEventProducerServer
}

// OrderMatch implements pb.EventProducerServer.
func (e *EventProducerServer) OrderMatch(context.Context, *pb.OrderMatchReq) (*pb.OrderMatchResp, error) {
	return &pb.OrderMatchResp{CorrelationId: "unimplemented"}, nil
}

func NewGrpcHandler() *EventProducerServer {
	return &EventProducerServer{}
}

// INTERFACE
var _ pb.EventProducerServer = (*EventProducerServer)(nil)
