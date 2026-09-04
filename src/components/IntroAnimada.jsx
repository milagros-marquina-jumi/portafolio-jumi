import React, { useCallback, useEffect, useRef, useState } from 'react'
import gsap from 'gsap'
import Logo from '/assets/img/logo.png'
import './intro.css'

const debeMostrarse = () => {
	if (typeof window === 'undefined') return false
	return !window.matchMedia('(prefers-reduced-motion: reduce)').matches
}

function IntroAnimada() {
	const [visible, setVisible] = useState(debeMostrarse)
	const raiz = useRef(null)
	const linea = useRef(null)

	const cerrar = useCallback(() => setVisible(false), [])

	const saltar = useCallback(() => {
		if (linea.current) linea.current.progress(1)
	}, [])

	useEffect(() => {
		if (!visible) return undefined

		document.body.style.overflow = 'hidden'
		const contexto = gsap.context(() => {
			const tl = gsap.timeline({ onComplete: cerrar })
			linea.current = tl

			tl.set('.intro-marca', { autoAlpha: 1 })
				.from('.intro-halo', { scale: 0, opacity: 0.9, duration: 1.1, ease: 'expo.out' }, 0)
				.to('.intro-halo', { scale: 2.6, opacity: 0, duration: 1.1, ease: 'expo.out' }, 0)
				.from('.intro-logo', {
					scale: 0.2,
					rotate: -35,
					autoAlpha: 0,
					duration: 1,
					ease: 'elastic.out(1, 0.55)',
				}, 0.1)
				.from('.intro-letra', {
					yPercent: 120,
					autoAlpha: 0,
					duration: 0.5,
					stagger: 0.035,
					ease: 'power3.out',
				}, 0.55)
				.from('.intro-rol', { autoAlpha: 0, y: 12, duration: 0.5, ease: 'power2.out' }, 0.95)
				.to('.intro-marca', { scale: 1.08, autoAlpha: 0, duration: 0.45, ease: 'power2.in' }, 1.85)
				.to('.intro-telon-arriba', { yPercent: -100, duration: 0.75, ease: 'power4.inOut' }, 2)
				.to('.intro-telon-abajo', { yPercent: 100, duration: 0.75, ease: 'power4.inOut' }, 2)
		}, raiz)

		return () => {
			contexto.revert()
			document.body.style.overflow = ''
		}
	}, [visible, cerrar])

	if (!visible) return null

	const nombre = 'MILAGROS'

	return (
		<div
			className="intro"
			ref={raiz}
			onClick={saltar}
			onKeyDown={(evento) => evento.key === 'Escape' && saltar()}
			role="button"
			tabIndex={0}
			aria-label="Saltar animacion de entrada"
		>
			<div className="intro-telon intro-telon-arriba"></div>
			<div className="intro-telon intro-telon-abajo"></div>
			<div className="intro-marca">
				<div className="intro-halo"></div>
				<img className="intro-logo" src={Logo} alt="" />
				<p className="intro-nombre">
					{nombre.split('').map((caracter, indice) => (
						<span className="intro-letra" key={`${caracter}-${indice}`}>{caracter}</span>
					))}
				</p>
				<p className="intro-rol">Software Architect &amp; Full-Stack Engineer</p>
			</div>
			<span className="intro-saltar">Toca para saltar</span>
		</div>
	)
}

export default IntroAnimada
