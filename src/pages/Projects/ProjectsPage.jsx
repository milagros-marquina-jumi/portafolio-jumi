import React, { useState } from 'react'
import Movile from '/assets/img/mockup-movil.webp'
import Web from '/assets/img/mockup-web.webp'
import { Link } from 'react-router-dom'
import { useNavigate } from 'react-router-dom'
import { BarLoader } from 'react-spinners'
import { getProjectsByType } from '../../data/projects'
import './projects.css'
import { useTranslation } from 'react-i18next'

function ProjectsPage() {
    const [t, i18n] = useTranslation("global");
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const totalWeb = getProjectsByType('web').length;
    const totalMovil = getProjectsByType('movil').length;
    const contar = (total) => (total === 1
        ? t('projects-page.count-one')
        : t('projects-page.count-many', { n: total }));

    const changeWebProjects = () => {
        setLoading(true);
        setTimeout(() => {
            navigate('/projects/web');
            setLoading(false);
        }, 1000);
    }
    const changeMovilProjects = () => {
        setLoading(true);
        setTimeout(() => {
            navigate('/projects/movil');
            setLoading(false);
        }, 1000);
    }

    if (loading) {
        return (
            <div className="loading-faster">
                <BarLoader color={'#E7AD47'} height={4} width={'100%'} loading={loading} />
            </div>
        )
    } else {
        return (
            <main className="section-page">
                <div className="section-projects">
                    <div className="encabezado-seccion">
                        <h1>{t('projects-page.heading')}</h1>
                        <p>{t('projects-page.subtitle')}</p>
                    </div>
                    <div className="projects">
                        <Link to="" className="card-project noSelect card-web noSelect" onClick={changeWebProjects}>
                            <div className="info-card">
                                <div className="info-description info-description-web">
                                    <p> {t('projects-page.title')} </p>
                                    <h1>Web</h1>
                                    <span className="contador-proyectos">{contar(totalWeb)}</span>
                                </div>
                            </div>
                            <img src={Web} alt="Web" />
                        </Link>
                        <Link to="" className="card-project noSelect card-movil noSelect" onClick={changeMovilProjects}>
                            <div className="info-card">
                                <div className="info-description">
                                    <p> {t('projects-page.title')} </p>
                                    <h1> {t('projects-page.type')} </h1>
                                    <span className="contador-proyectos">{contar(totalMovil)}</span>
                                </div>
                            </div>
                            <img src={Movile} alt="Móvile" />
                        </Link>
                    </div>
                </div >
            </main >
        )
    }
}

export default ProjectsPage