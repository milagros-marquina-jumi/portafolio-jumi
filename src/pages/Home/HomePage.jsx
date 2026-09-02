import React from 'react'
import DevJumi from '/assets/img/milagrosmarquina.png'
import DevRocket from '/assets/img/rocket.png'
import { Link } from 'react-router-dom'
import './home.css'
import { useTranslation } from 'react-i18next'

function Home() {
	const [t, i18n] = useTranslation("global");

	return (
		<main className="hero section-page">
			<div className="info-hero">
				<div className="description">
					<h1 className="uppercase"> {t('home-page.title')} <br /> <strong> MILAGROS JULISA MARQUINA MORA </strong> </h1>
					<p> {t('home-page.description')} </p>
					<br className="noSelect" /><br />
					<div className="container-bot">
						<Link to="/about-me" className="noSelect">
							<button className="btn-primary noSelect cursor-pointer">
								{t('home-page.btn-see-more')}
							</button>
						</Link>
						<div className="social-media">
							<a
								className="icon-social icon-linkedin noSelect"
								href="https://www.linkedin.com/in/milagros-marquina-jumi/"
								target="_blank"
								rel="noopener noreferrer"
							>
							</a>
							<a
								className="icon-social icon-github noSelect"
								href="https://github.com/milagros-marquina-jumi"
								target="_blank"
								rel="noopener noreferrer"
							>
							</a>
							<a
								className="icon-social icon-whatsapp noSelect"
								href="https://api.whatsapp.com/send?phone=51950135713&text=Hola%20Milagros!%20(◕‿◕)"
								target="_blank"
								rel="noopener noreferrer"
							>
							</a>
						</div>
					</div>
				</div>
			</div>
			<figure className="img-hero noSelect">
				<img src={DevRocket} alt="Rocket" />
			</figure>
			<div>
			</div>
			<figure className="dev-jumi-photo noSelect">
				<img src={DevJumi} alt="Milagros Marquina" />
			</figure>
		</main>
	)
}

export default Home