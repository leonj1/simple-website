import React from 'react';

function App() {
  return (
    <main className="container">
      <section>
        <hgroup>
          <h1>Welcome to Our Platform</h1>
          <p>Discover amazing features in our dark-themed interface</p>
        </hgroup>
      </section>

      <section>
        <div className="grid">
          <article>
            <header>
              <h3>Fast & Reliable</h3>
            </header>
            <p>Built with modern technologies for optimal performance and reliability.</p>
          </article>
          
          <article>
            <header>
              <h3>Secure</h3>
            </header>
            <p>Your data is protected with industry-standard security measures.</p>
          </article>
          
          <article>
            <header>
              <h3>User Friendly</h3>
            </header>
            <p>Intuitive design that makes complex tasks simple and enjoyable.</p>
          </article>
        </div>
      </section>

      <section>
        <div style={{ textAlign: 'center' }}>
          <button className="primary">Get Started</button>
          <button className="secondary" style={{ marginLeft: '1rem' }}>Learn More</button>
        </div>
      </section>

      <footer style={{ textAlign: 'center', marginTop: '3rem', paddingTop: '2rem', borderTop: '1px solid var(--muted-border-color)' }}>
        <p><small>© 2024 Your Company. All rights reserved.</small></p>
      </footer>
    </main>
  );
}

export default App;