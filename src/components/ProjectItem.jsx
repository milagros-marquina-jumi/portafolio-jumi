import React from 'react'

function ProjectItem(props) {
	const project = props.projects
	return (
		<div className={`project-item-${props.type} project-item noSelect`}>
			<div className={`container-item-${props.type} container-item`}>
				<div className={`info-item-${props.type} info-item`}>
					<h1>{project.name}</h1>
					<ul>
						{project.technologies.map(technologies => {
							return <li key={technologies}>{`• ${technologies}`}</li>
						})}
					</ul>
				</div>
				<img
					className={`item-img-${props.type}`}
					src={project.img}
					alt={`${project.name} img`}
				/>
			</div>
		</div>
	)
}

export default ProjectItem