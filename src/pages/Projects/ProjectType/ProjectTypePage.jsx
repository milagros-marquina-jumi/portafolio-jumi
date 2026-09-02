import { useState, useEffect } from "react";
import { Link, useParams, useSearchParams } from "react-router-dom";
import { getAllProjects } from "../../../data/projects";
import ProyectoItem from './../../../components/ProjectItem';
import './project_type.css';
import { useTranslation } from "react-i18next";

export function ProjectTypePage() {
    const [t] = useTranslation("global");
    const [searchParams, setSearchParams] = useSearchParams();
    const [selectedType, setSelectedType] = useState("");
    const [filter, setFilter] = useState("");
    const projects = getAllProjects();
    const { projectType } = useParams();

    useEffect(() => {
        setSelectedType(projectType);
        setFilter("");
        setSearchParams({ filter: "", type: projectType });
    }, [projectType]);

    const filteredProjects = projects.filter((project) => {
        if (!filter) {
            return project.type === selectedType;
        }
        return (
            project.type === selectedType &&
            project.name.toLowerCase().includes(filter.toLowerCase())
        );
    });

    const handleChange = (e) => {
        const newFilter = e.target.value;
        setFilter(newFilter);
        setSearchParams({ filter: newFilter, type: selectedType });
    };

    const clearSearch = () => {
        setFilter("");
        setSearchParams({ filter: "", type: selectedType });
    };

    const changeWebProjects = () => {
        setSelectedType("web");
        setFilter("");
        setSearchParams({ filter, type: "web" });
    };

    const changeMovilProjects = () => {
        setSelectedType("movil");
        setFilter("");
        setSearchParams({ filter, type: "movil" });
    };

    return (
        <div>
            <div className="project-type">
                <form className="search">
                    <input
                        placeholder={t('project-type-page.search')}
                        type="text"
                        className="input-textarea"
                        maxLength="50"
                        value={filter}
                        onChange={handleChange}
                    />
                    <button
                        className="btn-search noSelect cursor-pointer"
                        type="reset"
                        onClick={clearSearch}
                    ></button>
                </form>

                <div className="projects-filter">
                    <button
                        className={`filter-btn btn-web ${selectedType === "web" ? "active" : ""}`}
                        onClick={changeWebProjects}
                    >
                        {t('projects-page.title')} WEB
                    </button>

                    <button
                        className={`filter-btn btn-movil ${selectedType === "movil" ? "active" : ""}`}
                        onClick={changeMovilProjects}
                    >
                        {t('projects-page.title')} MOBILE
                    </button>
                </div>

                <br />

                <div className="projects-list noScrollBar">
                    {filteredProjects.length === 0 ? (
                        <p className="no-results">{t('project-type-page.no-results')}</p>
                    ) : (
                        filteredProjects.map((project) => (
                            <div key={project.id}>
                                <Link
                                    className="noSelect"
                                    to={`/projects/${project.type}/${project.id}`}
                                >
                                    <ProyectoItem
                                        imgClase={project.type}
                                        projects={project}
                                        type={project.type}
                                    />
                                </Link>
                            </div>
                        ))
                    )}
                </div>
            </div>
        </div>
    );
}
