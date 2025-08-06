package util

import (
	"context"
	"sync"
)

type ConcurrencyFunc func(ctx context.Context) error

type Concurrency struct {
	wg       sync.WaitGroup
	cancel   context.CancelFunc
	ctx      context.Context
	errChan  chan error
	funcList []ConcurrencyFunc
}

func NewConcurrency(ctx context.Context) *Concurrency {
	return &Concurrency{
		ctx:     ctx,
		errChan: make(chan error, 1),
	}
}

func (c *Concurrency) Add(f ConcurrencyFunc) {
	c.wg.Add(1)
	c.funcList = append(c.funcList, f)
}

func (c *Concurrency) Run() {
	c.ctx, c.cancel = context.WithCancel(c.ctx)
	for _, f := range c.funcList {
		go func(f ConcurrencyFunc) {
			defer c.wg.Done()
			select {
			case <-c.ctx.Done():
				return
			default:
			}
			if err := f(c.ctx); err != nil {
				select {
				case c.errChan <- err:
					c.cancel()
				default:
				}
			}
		}(f)
	}
}

func (c *Concurrency) Wait() {
	c.wg.Wait()
}

func (c *Concurrency) Err() error {
	select {
	case err := <-c.errChan:
		return err
	default:
		return nil
	}
}
