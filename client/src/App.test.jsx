import { render, screen, waitFor } from '@testing-library/react'
import { describe, it, expect, vi, afterEach } from 'vitest'
import '@testing-library/jest-dom'
import App from './App'

describe('App Component', () => {

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('renders ShopSmart title', async () => {

    global.fetch = vi.fn(() =>
      Promise.resolve({
        json: () =>
          Promise.resolve({
            status: 'ok',
            message: 'Backend Running',
            timestamp: 'now'
          })
      })
    )

    render(<App />)

    expect(screen.getByText(/ShopSmart/i)).toBeInTheDocument()

    // Wait for async state update to finish
    await waitFor(() => {
      expect(screen.getByText(/Backend Running/i)).toBeInTheDocument()
    })
  })

  it('shows loading initially', async () => {

    global.fetch = vi.fn(() =>
      new Promise(resolve =>
        setTimeout(() =>
          resolve({
            json: () =>
              Promise.resolve({
                status: 'ok',
                message: 'Backend Running',
                timestamp: 'now'
              })
          }), 100
        )
      )
    )

    render(<App />)

    expect(screen.getByText(/Loading backend status/i)).toBeInTheDocument()
  })

  it('renders backend data after fetch', async () => {

    global.fetch = vi.fn(() =>
      Promise.resolve({
        json: () =>
          Promise.resolve({
            status: 'ok',
            message: 'Backend Running',
            timestamp: '12345'
          })
      })
    )

    render(<App />)

    expect(await screen.findByText(/Backend Running/i)).toBeInTheDocument()
    expect(await screen.findByText(/12345/i)).toBeInTheDocument()
  })
})
