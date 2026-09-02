import React from 'react'
import Swal from 'sweetalert2'
import DevRocket from '/assets/img/rocket.png'
import emailjs from 'emailjs-com'
import './contact.css'
import { useTranslation } from 'react-i18next'

export function Contact() {
	const [t, i18n] = useTranslation("global");

	const SendEmail = async (e) => {
		e.preventDefault();

		emailjs.sendForm(
			"service_vgizk6g",
			"template_6u5l0nn",
			e.target,
			"n6GePiP2Xhr2Lr_X3"
		).then(res => {
			console.log(res);
			Swal.fire({
				position: 'top-end',
				icon: 'success',
				title: 'El mensaje se envió con éxito',
				showConfirmButton: false,
				allowOutsideClick: true,
				timer: 3000,
				timerProgressBar: true,
				toast: true,
			})
			setTimeout(() => {
				/* window.location.reload(); */
				document.getElementById("name_user").value = "";
				document.getElementById("email_user").value = "";
				document.getElementById("message_user").value = "";
				document.getElementById("btn-send").disabled = true;
			}, 1);
		}).catch(err => {
			console.log(err);
			Swal.fire({
				position: 'top-end',
				icon: 'error',
				title: 'Ocurrió un error, por favor inténtalo mas tarde',
				showConfirmButton: false,
				toast: true,
			})
		})

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
						<form autoComplete="off" onSubmit={SendEmail}>
							<input
								placeholder={t('contact-page.name')}
								required
								className="input-textarea capitalize"
								name="name"
								type="text"
								maxLength="40"
								id="name_user"
							/>
							<br />
							<input
								required
								placeholder={t('contact-page.email')}
								className="input-textarea"
								name="user_email"
								type="email"
								maxLength="100"
								id="email_user"
							/>
							<br />
							<textarea
								placeholder={t('contact-page.message')}
								required
								className="input-textarea"
								name="message"
								rows="5"
								id="message_user"
							></textarea>
							<div className="noSelect">
								<button className="btn-primary cursor-pointer btn-send">{t('contact-page.btn-send')}</button>
							</div>
						</form>
					</div>
				</div>
				<div className="illustration">
					<figure className="img-send-email noSelect">
						<img src={DevRocket} alt="Send email" />
					</figure>
				</div>
			</div>
		</main>
	)
}

export default Contact
