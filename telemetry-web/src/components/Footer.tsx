import * as React from 'react';
import logo from '../../assets/logo.svg';
import './Footer.css';

export class Footer extends React.Component {
  public render() {
    return (
      <footer className="Footer">
        <div className="Footer-content">
          <img src={logo} alt="Telemetry Logo" />
          {/* <p>© 2024 Xerberus DAO LLC. All rights reserved.</p> */}
          <div className="Footer-links">
            <a href="https://app.xerberus.io" target="_blank" rel="noopener noreferrer">App</a>
            <a href="https://www.xerberus.io" target="_blank" rel="noopener noreferrer">Website</a>

          </div>
        </div>
      </footer>
    );
  }
} 