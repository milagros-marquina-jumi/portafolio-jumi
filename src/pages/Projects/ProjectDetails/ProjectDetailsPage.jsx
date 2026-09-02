import { useMemo } from "react"
import { useParams } from "react-router-dom"
import { getProjecById } from "../../../data/projects"
import ProjectButtons from './../../../components/ProjectButtons'
import './project_details.css'
import { useTranslation } from "react-i18next"

export function ProjectDetailsPage() {
    const [t, i18n] = useTranslation("global");
    const { projectName } = useParams();

    const projectId = useMemo(() => getProjecById(projectName), [projectName]);

    const {
        name,
        description,
        technologies,
        img_details,
        type,
        link,
        app_store,
        github_link,
    } = projectId;

    return (
        <div>
            <main className="section-page">
                <div className="details-container">
                    <div className="img-details-project">
                        <img
                            className="noSelect"
                            src={img_details}
                            alt={`${name} img`}
                        />
                    </div>
                    <div className="info-details-project">
                        <div>
                            <h1 className="project-type-title uppercase">{name}</h1>
                            <br />
                            <h2>{t('project-details-page.subtitle')} {type}</h2><br />
                            <br />
                            <div className="details-paragraph">
                                <p>{description}</p>
                            </div>
                            <ul className="details-list">
                                {technologies.map((tech) => (
                                    <li key={tech}>• {tech}</li>
                                ))}
                            </ul>
                            <br />
                            <div className="btns-details">
                                <ProjectButtons
                                    link={github_link}
                                    css={'github'}
                                    text={'GitHub'}
                                />
                                <ProjectButtons
                                    link={link}
                                    css={'link'}
                                    text={'Sitio Web'}
                                />
                                <ProjectButtons
                                    link={app_store}
                                    css={'app-store'}
                                    text={'App Store'}
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
