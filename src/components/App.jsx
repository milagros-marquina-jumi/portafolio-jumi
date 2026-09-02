import React, { useState } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import Layout from './Layout'
import NotFoundPage from '../pages/NotFound/NotFoundPage'
import HomePage from '../pages/Home/HomePage'
import AboutMePage from '../pages/AboutMe/AboutMePage'
import ContactPage from '../pages/Contact/ContactPage'
import ProjectsPage from '../pages/Projects/ProjectsPage'
import { ProjectTypePage } from '../pages/Projects/ProjectType/ProjectTypePage'
import { ProjectDetailsPage } from '../pages/Projects/ProjectDetails/ProjectDetailsPage'
import styled, { ThemeProvider } from 'styled-components'
import langenglish from '/assets/img/lang-english.png'
import langspanish from '/assets/img/lang-spanish.png'
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
	const changeLanguageEs = () => {
		i18n.changeLanguage("en");
	}
	const changeLanguageEn = () => {
		i18n.changeLanguage("es")
	}

	return (
		<ThemeProvider theme={theme === "dark" ? lightTheme : darkTheme}>
			<GlobalTheme />
			<StyledApp>
				<div className="mode-language">
					<div className="noSelect">
						<img className="cursor-pointer" src={lightMode} alt="" onClick={() => toggleTheme()} />
					</div>
					<div className="noSelect" id="language-english" onClick={() => changeLanguageEs()}>
						<img className="cursor-pointer" src={langenglish} alt="" />
					</div>
					<div className="noSelect" id="language-spanish" onClick={() => changeLanguageEn()}>
						<img className="cursor-pointer" src={langspanish} alt="" />
					</div>
				</div>
				<BrowserRouter>
					<Layout>
						<Routes>
							<Route path="*" element={<NotFoundPage />} />
							<Route path="/" element={<Navigate to="/portfolio-jumi" />} />
							<Route exact path="/portfolio-jumi" element={<HomePage />} />
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
