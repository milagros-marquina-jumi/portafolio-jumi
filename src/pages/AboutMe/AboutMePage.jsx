import React from 'react'
import { Link } from 'react-router-dom'
import me from '/assets/img/jumi-saludando.webp'
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
								<li>• Java (8 - 21)</li>
								<li>• TypeScript</li>
								<li>• JavaScript</li>
								<li>• Node.js</li>
								<li>• Kotlin</li>
							</ul>
							<ul>
								<li>• Angular</li>
								<li>• React</li>
								<li>• Vue</li>
								<li>• Microfrontends</li>
								<li>• TailwindCSS</li>
							</ul>
							<ul>
								<li>• Spring Boot</li>
								<li>• NestJS</li>
								<li>• Quarkus</li>
								<li>• GraphQL</li>
								<li>• Kafka</li>
							</ul>
							<ul>
								<li>• PostgreSQL</li>
								<li>• MongoDB</li>
								<li>• AWS / Azure</li>
								<li>• Docker / Kubernetes</li>
								<li>• RAG / LLMs</li>
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
