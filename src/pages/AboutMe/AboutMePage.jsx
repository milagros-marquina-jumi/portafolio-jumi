import React from 'react'
import { Link } from 'react-router-dom'
import me from '/assets/img/milagrosmarquina.png'
import { useTranslation } from 'react-i18next'
import './about_me.css'

function AboutMePage() {
	const [t, i18n] = useTranslation("global");

	return (
		<main className="section-page">
			<div className="container-about">
				<div className="border-gradient section-about" id="box">
					<div className="about-me-img noSelect">
						<img src={me} alt="Milagros Marquina" />
					</div>
					<div className="about-me-info">
						<h1>
							{t('about-me-page.title')}
						</h1>
						<br />
						<p>
							{t('about-me-page.description')}
						</p>
						<br />
						<br />
						<h2>
							{t('about-me-page.my-skills')}
						</h2>
						<br />
						<div className="list-info-about-me">
							<ul>
								<li>• HTML</li>
								<li>• CSS</li>
								<li>• SASS</li>
								<li>• JavaScript</li>
							</ul>
							<ul>
								<li>• React</li>
								<li>• Angular</li>
								<li>• NodeJS</li>
								<li>• Java</li>
							</ul>
							<ul>
								<li>• Git / GitHub</li>
								<li>• UI / UX</li>
								<li>• Figma</li>
								<li>• Photoshop</li>
							</ul>
							<ul>
								<li>• MongoDB</li>
								<li>• MySQL</li>
								<li>• PostgreSQL</li>
								<li>• Firebase</li>
							</ul>
						</div>
						<div className="about-me-info__links noSelect">
							<Link className="btn-download" to="/projects">
								{t('about-me-page.see-projects')}
							</Link>
						</div>
					</div>
				</div>
			</div>
		</main>
	)
}

export default AboutMePage
