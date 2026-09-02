import React from 'react';
import ReactDOM from 'react-dom/client';  // Asegúrate de importar desde 'react-dom/client'
import './index.css';
import App from './components/App';
import GlobalStyle from './assets/styles/globalStyles';  // Ruta correcta
import { I18nextProvider } from 'react-i18next';
import i18next from 'i18next';

import global_es from "./translations/es/global.json";
import global_en from "./translations/en/global.json";

// Configuración de i18next para la internacionalización
i18next.init({
  interpolation: { escapeValue: false },
  lng: 'es',
  resources: {
    es: { global: global_es },
    en: { global: global_en },
  }
});

// Usamos createRoot en lugar de render para React 18
const root = ReactDOM.createRoot(document.getElementById('root'));

// Renderizado de la aplicación con i18next y GlobalStyles
root.render(
  <React.StrictMode>
    <I18nextProvider i18n={i18next}>
      <GlobalStyle />
      <App />
    </I18nextProvider>
  </React.StrictMode>
);
