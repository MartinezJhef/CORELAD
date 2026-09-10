import React, { StrictMode, Component } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

class GlobalErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error atrapado por GlobalErrorBoundary:', error, errorInfo);
    this.setState({ errorInfo });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '2rem', background: '#1e1e1e', color: '#ff6b6b', fontFamily: 'monospace', minHeight: '100vh' }}>
          <h2 style={{ color: '#FEE11A' }}>⚠️ Error en tiempo de ejecución en React:</h2>
          <div style={{ background: '#2d2d2d', padding: '1rem', borderRadius: '8px', marginTop: '1rem', color: '#fff' }}>
            <strong>{this.state.error && this.state.error.toString()}</strong>
          </div>
          <pre style={{ background: '#000', padding: '1rem', borderRadius: '8px', marginTop: '1rem', overflowX: 'auto', fontSize: '0.85rem', color: '#88e0ef' }}>
            {this.state.error && this.state.error.stack}
          </pre>
          <pre style={{ background: '#111', padding: '1rem', borderRadius: '8px', marginTop: '1rem', color: '#aaa', fontSize: '0.8rem' }}>
            {this.state.errorInfo && this.state.errorInfo.componentStack}
          </pre>
        </div>
      );
    }
    return this.props.children;
  }
}

// Atrapador de errores globales no manejados
window.addEventListener('error', (event) => {
  const root = document.getElementById('root');
  if (root && (!root.innerHTML || root.innerHTML.trim() === '')) {
    root.innerHTML = `
      <div style="padding: 2rem; background: #1e1e1e; color: #ff6b6b; font-family: monospace;">
        <h2 style="color: #FEE11A;">⚠️ Error Global de JavaScript:</h2>
        <div style="background: #2d2d2d; padding: 1rem; border-radius: 8px; margin-top: 1rem; color: #fff;">
          <strong>${event.message}</strong>
        </div>
        <p style="color: #aaa; margin-top: 0.5rem;">Archivo: ${event.filename} (Línea: ${event.lineno})</p>
      </div>
    `;
  }
});

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <GlobalErrorBoundary>
      <App />
    </GlobalErrorBoundary>
  </StrictMode>,
)
