import React from 'react'
import Error404 from '/assets/img/error-404.webp'
import { Link } from 'react-router-dom'
import './not_found.css'

const NotFoundPage = () => {
    return (
        <main className="section-page">
            <div className="not-found-page">
                <div>
                    <div className="container noSelect">
                        <img src={Error404} alt="Error404" />
                    </div>
                </div>
                <div className="info-404">
                    <h1>404 Página NO encontrada! :(</h1>
                    <Link className="noSelect" to="/">
                        Regresa a INICIO
                    </Link>
                </div>
            </div>
        </main>
    )
}

export default NotFoundPage
