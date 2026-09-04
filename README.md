
# **Milagros Marquina — Software Architect & Full-Stack Engineer**

Portafolio personal. Sitio estático en React que muestra proyectos, experiencia
y un formulario de contacto, en español e inglés.

**En vivo:** [milagros-marquina-jumi.github.io/portafolio-jumi](https://milagros-marquina-jumi.github.io/portafolio-jumi)

---

## **Características**

- **Dos idiomas** (español e inglés) con i18next, conmutables sin recargar.
- **Modo oscuro y claro.**
- **Responsivo**, con el punto de corte principal en 1024px, donde la
  navegación pasa a menú hamburguesa.
- **Formulario de contacto** con validación en vivo y reCAPTCHA v2.
- **Animación de entrada** con GSAP y humo animado en CSS.
- **Sin backend ni base de datos**: los proyectos viven en `src/data/projects.js`.

Todas las animaciones respetan `prefers-reduced-motion`.

---

## **Tecnologías**

| Área | Herramientas |
|---|---|
| Interfaz | React 19, Vite 6, React Router 7 |
| Estilos | Styled-Components, CSS por página |
| Idiomas | i18next |
| Animación | GSAP |
| Formulario | EmailJS, reCAPTCHA v2, SweetAlert2 |
| Calidad | TypeScript, ESLint |
| Despliegue | GitHub Pages vía GitHub Actions |

---

## **Instalación**

```bash
git clone https://github.com/milagros-marquina-jumi/portafolio-jumi.git
cd portafolio-jumi
npm ci --ignore-scripts
npm run dev
```

El sitio queda en **http://localhost:5173/portafolio-jumi/**. La ruta base no es
la raíz: viene de `base` en `vite.config.js`, que tiene que coincidir con el
nombre del repositorio o todos los assets dan 404.

**`--ignore-scripts` no es opcional.** Un `preinstall` o un `postinstall` de una
dependencia comprometida se ejecutaría al instalar, con acceso a la red y sin
que nadie lo lea; ese fue el vector del incidente del 2026-09-01 que obligó a
reiniciar este repositorio. `CI=true` **no** lo reemplaza: son cosas distintas.

### Activar el hook local

No viaja en el repositorio, hay que activarlo una vez por clon:

```bash
git config core.hooksPath .githooks
git config --local user.name  "Tu Nombre"
git config --local user.email "tu@correo"
git config --local --add security.allowedEmail "tu@correo"
```

Ese mismo correo tiene que estar en `.github/autores-permitidos.txt`, que es lo
que valida el CI.

---

## **Scripts**

| Comando | Qué hace |
|---|---|
| `npm run dev` | Servidor de desarrollo |
| `npm run build` | `tsc -b` y compilación de producción en `dist/` |
| `npm run lint` | ESLint sobre todo el proyecto |
| `npm run preview` | Sirve `dist/` en local |

**No hay `npm run deploy`.** Publicar es automático: cada push a `master`
dispara `.github/workflows/deploy.yml`. El comando manual existía cuando Pages
se servía desde la rama `gh-pages`, y mantenerlo ahora sería peor que no
tenerlo, porque publicaría en una rama que ya no sirve el sitio y parecería que
funcionó.

---

## **Ramas y flujo**

```
feature/*  ->  develop  ->  master  ->  se publica solo
```

`master` está protegida por un ruleset: commits firmados, revisión obligatoria
sobre los archivos de control, y los dos checks de abajo en verde. Los pull
requests hacia `master` solo se aceptan desde `develop`, y eso lo impone
`check-origen.sh`, porque los rulesets de GitHub no saben restringir la rama de
origen.

---

## **Seguridad**

Este repositorio está en una cuenta personal, fuera de la organización
`mimotech-projects`, y una GitHub Action privada solo la pueden invocar
repositorios de la misma organización. Por eso los controles de
[mimotech-security](https://github.com/mimotech-projects/mimotech-security) están
**vendorizados**: son copias dentro de `.github/`, no una referencia externa.

`.github/motor-version.txt` anota de qué versión vienen y con qué sumas. **Esas
copias no se actualizan solas**: hay que volver a ejecutar `vendorizar.sh` desde
el motor.

Dos flujos de trabajo vigilan cada cambio:

- **`Escanear configuraciones y assets`** — malware, archivos prohibidos,
  identidades no autorizadas, bits de ejecución no declarados y un solo gestor
  de paquetes sin scripts de instalación ocultos.
- **`Compilar y revisar el codigo`** — instala, compila y pasa el lint. Existe
  porque un control de seguridad en verde no dice que el proyecto funcione: hubo
  pull requests que pasaron toda la seguridad y dejaron la rama sin poder
  instalarse.

El hook `pre-commit` repite las mismas comprobaciones antes de cada commit. Se
salta con `--no-verify`, y por eso las mismas verificaciones corren en CI sobre
la rama protegida.

### Claves

La *site key* de reCAPTCHA y los identificadores de EmailJS están en el código
**a propósito**: son públicos por diseño y viajan al navegador de cualquier
forma. Ponerlos en un `.env` no los ocultaría, porque Vite mete las variables
`VITE_*` en el bundle igual.

La *secret key* de reCAPTCHA **no está aquí** y no debe estarlo: vive solo en el
panel de EmailJS.

---

## **Contacto**

- **LinkedIn:** [milagros-marquina-jumi](https://www.linkedin.com/in/milagros-marquina-jumi/)
- **GitHub:** [milagros-marquina-jumi](https://github.com/milagros-marquina-jumi)
