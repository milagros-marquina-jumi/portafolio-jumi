import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link } from 'react-router-dom'
import Logo from '/assets/img/logo.png'

export function Navbar() {
	const [t, i18n] = useTranslation("global");

	const [show, setShow] = useState(false);

	function showSwitch() {
		return setShow(!show);
	}

	return (
		<header>
			<Link className="noSelect" to="/">
				<figure className="logo">
					<img src={Logo} alt="logo" />
				</figure>
			</Link>
			<nav className="uppercase">
				<ol className={show ? "active links" : "links"}>
					<li>
						<Link
							onClick={() => showSwitch()}
							className="noSelect link-navbar"
							id="HomePage"
							to="/"
						>
							{t('navbar-page.home')}
						</Link>
					</li>
					<li>
						<Link
							onClick={() => showSwitch()}
							className="noSelect link-navbar"
							id="AboutMePage"
							to="/about-me"
						>
							{t('navbar-page.about-me')}
						</Link>
					</li>
					<li>
						<Link
							onClick={() => showSwitch()}
							className="noSelect link-navbar"
							id="ProjectsPage"
							to="/projects"
						>
							{t('navbar-page.projects')}
						</Link>
					</li>
					<li>
						<Link
							onClick={() => showSwitch()}
							className="noSelect link-navbar"
							id="ContactPage"
							to="/contact"
						>
							{t('navbar-page.contact')}
						</Link>
					</li>
				</ol>
			</nav>
			<div className="menu">
				<div
					onClick={() => showSwitch()}
					className={show ? 'bars-button active cursor-pointer' : 'bars-button cursor-pointer'}>
					<span></span>
					<span></span>
					<span></span>
				</div>
			</div>
		</header>
	)
}

export default Navbar