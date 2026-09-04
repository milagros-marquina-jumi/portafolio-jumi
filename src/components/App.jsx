import React, { useState } from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Layout from './Layout'
import IntroAnimada from './IntroAnimada'
import NotFoundPage from '../pages/NotFound/NotFoundPage'
import HomePage from '../pages/Home/HomePage'
import AboutMePage from '../pages/AboutMe/AboutMePage'
import ContactPage from '../pages/Contact/ContactPage'
import ProjectsPage from '../pages/Projects/ProjectsPage'
import { ProjectTypePage } from '../pages/Projects/ProjectType/ProjectTypePage'
import { ProjectDetailsPage } from '../pages/Projects/ProjectDetails/ProjectDetailsPage'
import styled, { ThemeProvider } from 'styled-components'
import lightMode from '/assets/img/light-mode.png'
import { useTranslation } from 'react-i18next'
import { darkTheme, GlobalTheme, lightTheme } from '../assets/styles/theme'

const StyledApp = styled.div``;

function App() {
	const [theme, setTheme] = useState("light");
	const [t, i18n] = useTranslation("global");

	const toggleTheme = () => {
		theme === "light" ? setTheme("dark") : setTheme("light");
	}
	const idioma = i18n.resolvedLanguage || i18n.language;

	return (
		<ThemeProvider theme={theme === "dark" ? lightTheme : darkTheme}>
			<GlobalTheme />
			<StyledApp>
				<IntroAnimada />
				<div className="mode-language">
					<button
						type="button"
						className="btn-tema noSelect cursor-pointer"
						onClick={() => toggleTheme()}
						aria-label={theme === "light" ? "Modo oscuro" : "Modo claro"}
					>
						<img src={lightMode} alt="" />
					</button>
					<div className="selector-idioma noSelect" role="group" aria-label="Idioma">
						<button
							type="button"
							className={`btn-idioma cursor-pointer ${idioma === "es" ? "activo" : ""}`}
							onClick={() => i18n.changeLanguage("es")}
							aria-pressed={idioma === "es"}
						>
							ES
						</button>
						<button
							type="button"
							className={`btn-idioma cursor-pointer ${idioma === "en" ? "activo" : ""}`}
							onClick={() => i18n.changeLanguage("en")}
							aria-pressed={idioma === "en"}
						>
							EN
						</button>
					</div>
				</div>
				<BrowserRouter basename={import.meta.env.BASE_URL}>
					<Layout>
						<Routes>
							<Route path="*" element={<NotFoundPage />} />
							<Route exact path="/" element={<HomePage />} />
							<Route exact path="/about-me" element={<AboutMePage />} />
							<Route exact path="/contact" element={<ContactPage />} />
							<Route exact path="/projects" element={<ProjectsPage />} />
							<Route exact path="/projects/:projectType" element={<ProjectTypePage />} />
							<Route exact path="/projects/:projectType/:projectName" element={<ProjectDetailsPage />} />
						</Routes>
					</Layout>
				</BrowserRouter>
			</StyledApp>
		</ThemeProvider >
	)
}

export default App
