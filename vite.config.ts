import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  // El repositorio se llama portafolio-jumi y GitHub Pages sirve el sitio en
  // https://milagros-marquina-jumi.github.io/portafolio-jumi/. Si esto no
  // coincide con el nombre del repositorio, todos los assets dan 404 y la
  // pagina queda en blanco.
  //
  // Antes esto era un ternario sobre process.env.NODE_ENV con las dos ramas
  // devolviendo el mismo valor. Se quita porque no decidia nada y obligaba a
  // depender de @types/node, que dejo de venir de arrastre al subir
  // @vitejs/plugin-react a 6.
  base: '/portafolio-jumi/',
  build: {
    chunkSizeWarningLimit: 1000,
  },
})
