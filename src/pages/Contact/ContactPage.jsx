import React, { useCallback, useEffect, useRef, useState } from 'react'
import Swal from 'sweetalert2'
import Hablemos from '/assets/img/jumi-hablemos.webp'
import emailjs from 'emailjs-com'
import './contact.css'
import { useTranslation } from 'react-i18next'

const SERVICE_ID = 'service_60ixqcb'
const TEMPLATE_ID = 'template_6u5l0nn'
const PUBLIC_KEY = 'n6GePiP2Xhr2Lr_X3'
const RECAPTCHA_SITE_KEY = '6LftPqktAAAAANBsXUF1m4AytGsQS2eGdbFWGKuA'

const VALORES_INICIALES = { name: '', user_email: '', message: '' }

export function Contact() {
	const [t] = useTranslation('global')

	const [valores, setValores] = useState(VALORES_INICIALES)
	const [tocados, setTocados] = useState({})
	const [enviando, setEnviando] = useState(false)
	const [captchaResuelto, setCaptchaResuelto] = useState(false)

	const formRef = useRef(null)
	const captchaRef = useRef(null)
	const widgetId = useRef(null)

	const validar = useCallback((campo, valor) => {
		const limpio = valor.trim()
		if (campo === 'name') {
			if (!limpio) return t('contact-page.name-required')
			if (limpio.length < 2) return t('contact-page.name-short')
			return ''
		}
		if (campo === 'user_email') {
			if (!limpio) return t('contact-page.email-required')
			if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(limpio)) return t('contact-page.email-invalid')
			return ''
		}
		if (!limpio) return t('contact-page.message-required')
		if (limpio.length < 10) return t('contact-page.message-short')
		return ''
	}, [t])

	const errores = {
		name: validar('name', valores.name),
		user_email: validar('user_email', valores.user_email),
		message: validar('message', valores.message),
	}
	const formularioValido = !errores.name && !errores.user_email && !errores.message

	const alCambiar = (evento) => {
		const { name, value } = evento.target
		setValores((previos) => ({ ...previos, [name]: value }))
		setTocados((previos) => ({ ...previos, [name]: true }))
	}

	const alSalir = (evento) => {
		const { name } = evento.target
		setTocados((previos) => ({ ...previos, [name]: true }))
	}

	const errorVisible = (campo) => (tocados[campo] ? errores[campo] : '')

	useEffect(() => {
		let cancelado = false

		const dibujar = () => {
			if (cancelado) return
			if (!window.grecaptcha || !window.grecaptcha.render) {
				window.setTimeout(dibujar, 200)
				return
			}
			if (widgetId.current !== null || !captchaRef.current) return
			if (captchaRef.current.childElementCount > 0) return

			widgetId.current = window.grecaptcha.render(captchaRef.current, {
				sitekey: RECAPTCHA_SITE_KEY,
				theme: 'dark',
				callback: () => setCaptchaResuelto(true),
				'expired-callback': () => setCaptchaResuelto(false),
				'error-callback': () => setCaptchaResuelto(false),
			})
		}

		dibujar()
		return () => {
			cancelado = true
		}
	}, [])

	const reiniciarCaptcha = () => {
		setCaptchaResuelto(false)
		if (window.grecaptcha && widgetId.current !== null) {
			window.grecaptcha.reset(widgetId.current)
		}
	}

	const avisar = (icon, title) =>
		Swal.fire({
			position: 'top-end',
			icon,
			title,
			showConfirmButton: false,
			timer: icon === 'success' ? 3000 : 6000,
			timerProgressBar: true,
			toast: true,
			allowOutsideClick: true,
		})

	const SendEmail = async (evento) => {
		evento.preventDefault()
		setTocados({ name: true, user_email: true, message: true })
		if (!formularioValido || !captchaResuelto || enviando) return

		setEnviando(true)
		try {
			await emailjs.sendForm(SERVICE_ID, TEMPLATE_ID, evento.target, PUBLIC_KEY)
			setValores(VALORES_INICIALES)
			setTocados({})
			reiniciarCaptcha()
			avisar('success', t('contact-page.success'))
		} catch (error) {
			const estado = error?.status
			const detalle = error?.text || error?.message || 'sin detalle'
			let mensaje = t('contact-page.error-generic')
			if (estado === 426 || estado === 429) mensaje = t('contact-page.error-quota')
			if (/captcha/i.test(detalle)) mensaje = t('contact-page.error-captcha')
			reiniciarCaptcha()
			avisar('error', `${mensaje} (${estado ?? 'sin codigo'}: ${detalle})`)
		} finally {
			setEnviando(false)
		}
	}

	return (
		<main className="section-page">
			<div className="form-contact">
				<div className="form">
					<div className="container-form">
						<div className="media-form">
							<div className="social-media">
								<a
									className="icon-social-contact icon-linkedin noSelect"
									href="https://www.linkedin.com/in/milagros-marquina-jumi/"
									target="_blank"
									rel="noopener noreferrer"
								>
								</a>
								<a
									className="icon-social-contact icon-github noSelect"
									href="https://github.com/milagros-marquina-jumi"
									target="_blank"
									rel="noopener noreferrer"
								>
								</a>
								<a
									className="icon-social-contact icon-whatsapp noSelect"
									href="https://api.whatsapp.com/send?phone=51950135713&text=Hola%20Milagros!%20(◕‿◕)"
									target="_blank"
									rel="noopener noreferrer"
								>
								</a>
							</div>
						</div>
						<form autoComplete="off" onSubmit={SendEmail} ref={formRef} noValidate>
							<input
								placeholder={t('contact-page.name')}
								className={`input-textarea capitalize ${errorVisible('name') ? 'input-invalido' : ''}`}
								name="name"
								type="text"
								maxLength="40"
								id="name_user"
								value={valores.name}
								onChange={alCambiar}
								onBlur={alSalir}
								aria-invalid={Boolean(errorVisible('name'))}
							/>
							<p className="mensaje-error" role="alert">{errorVisible('name')}</p>
							<input
								placeholder={t('contact-page.email')}
								className={`input-textarea ${errorVisible('user_email') ? 'input-invalido' : ''}`}
								name="user_email"
								type="email"
								maxLength="100"
								id="email_user"
								value={valores.user_email}
								onChange={alCambiar}
								onBlur={alSalir}
								aria-invalid={Boolean(errorVisible('user_email'))}
							/>
							<p className="mensaje-error" role="alert">{errorVisible('user_email')}</p>
							<textarea
								placeholder={t('contact-page.message')}
								className={`input-textarea ${errorVisible('message') ? 'input-invalido' : ''}`}
								name="message"
								rows="4"
								id="message_user"
								value={valores.message}
								onChange={alCambiar}
								onBlur={alSalir}
								aria-invalid={Boolean(errorVisible('message'))}
							></textarea>
							<p className="mensaje-error" role="alert">{errorVisible('message')}</p>
							<div className="pie-form">
								<div className="captcha" ref={captchaRef}></div>
								<div className="noSelect">
									<button
										type="submit"
										id="btn-send"
										className="btn-primary cursor-pointer btn-send"
										disabled={!formularioValido || !captchaResuelto || enviando}
										title={!captchaResuelto ? t('contact-page.captcha') : undefined}
									>
										{enviando ? t('contact-page.sending') : t('contact-page.btn-send')}
									</button>
								</div>
							</div>
						</form>
					</div>
				</div>
				<div className="illustration">
					<figure className="img-send-email noSelect">
						<img src={Hablemos} alt="Hablemos" />
					</figure>
				</div>
			</div>
		</main>
	)
}

export default Contact
