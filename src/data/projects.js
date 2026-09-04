let projects = [
    {
        id: 'portafolio-web',
        name: 'Milagros Marquina',
        description: 'Es mi sitio web donde podrás conocer un poco sobre mí y los proyectos que he realizado.',
        technologies: ['ReactJS', 'HTML', 'CSSs', 'JavaScript', 'EmailJS'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/milagrosmarquina-web.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/milagrosmarquina-web-detail.webp`,
        type: 'web',
        link: 'https://milagros-marquina-jumi.github.io/portafolio-jumi',
        app_store: '',
        github_link: 'https://github.com/milagros-marquina-jumi/portafolio-jumi',
    },
    {
        id: 'restaurante-movil',
        name: 'Restaurante Sponge',
        description: 'El proyecto lo desarrollé con el objetivo de que cada sistema de los restaurantes sea más entretenido a la hora de registrar algún pedido.',
        technologies: ['Android', 'Kotlin', 'Retrofit'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil-detail.webp`,
        type: 'movil',
        link: '',
        app_store: 'https://restauranteesponjamovil.com',
        github_link: 'https://github.com/milagros-marquina-jumi/RestauranteEsponja.com',
    },

    {
        id: 'subasta-web',
        name: 'Subasta Online EsoEsMio',
        description: 'Proyecto que tiene como objetivo realizar una interacción mas cercana entre los participantes de una subasta con los ofertantes.',
        technologies: ['Angular 12', 'Mongodb', 'NodeJS'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/subastaonline-web.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/subastaonline-web-detail.webp`,
        type: 'web',
        link: 'https://subastasonline.com',
        app_store: '',
        github_link: 'https://github.com/milagros-marquina-jumi/SubastaOnline.com',
    },
    {
        id: 'restaurante-web',
        name: 'Restaurante PikaYa',
        description: 'El proyecto lo desarrollé con el objetivo de que cada sistema de los restaurantes sea más entretenido a la hora de registrar algún pedido.',
        technologies: ['Angular 11', 'Java', 'SpringBoot', 'Bootstrap'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/restaurante-web.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/restaurante-web-detail.webp`,
        type: 'web',
        link: 'https://restaurantepikayaweb.com',
        app_store: '',
        github_link: 'https://github.com/milagros-marquina-jumi/RestaurantePikaya.com',
    },
    {
        id: 'comfeco-web',
        name: 'Rediseño COMFECO',
        description: 'Proyecto que realicé con el objetivo de rediseñar el sitio web de Community Fest and Code (COMFECO).',
        technologies: ['Angular', 'Material', 'HTML', 'CSS'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/comfeco-web.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/comfeco-web-detail.webp`,
        type: 'web',
        link: 'https://proyectocomfeco.com',
        app_store: '',
        github_link: 'https://github.com/milagros-marquina-jumi/ProyectoComfeco.com',
    },
    {
        id: 'socialmedia-web',
        name: 'Red Social Space',
        description: 'Red social que tiene como objetivo facilitar la comunicación entre los usuarios de un espacio.',
        technologies: ['ReactJS', 'Node', 'API Rest', 'MongoDB', 'Express'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/socialmedia-web.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/socialmedia-web-detail.webp`,
        type: 'web',
        link: 'https://redsocialspace.com',
        app_store: '',
        github_link: 'https://github.com/milagros-marquina-jumi/RedSocialSpace.com',
    },
    {
        id: 'kitvskat-web',
        name: 'Educación Kit vs Kat',
        description: 'Sitio web educativo que brinda asesorías en diferentes materias de clases, así mismo, proporciona materiales adicionales para sus usuarios.',
        technologies: ['Angular', 'HTML', 'CSS', 'JavaScript'],
        img: `${import.meta.env.BASE_URL}assets/img/projects/kitvskat-web.webp`,
        img_details: `${import.meta.env.BASE_URL}assets/img/projects/kitvskat-web-detail.webp`,
        type: 'web',
        link: 'https://kitvskateducacion.com',
        app_store: '',
        github_link: 'https://github.com/milagros-marquina-jumi/KitvsKatEducacion.com',
    },
    /*     {
           id: 'newsapp-movil',
           name: 'Noticias Galaxy',
           description: 'Proyecto en el que consume la API newsapi en el que las noticias son en tiempo real y podrá buscar, agregar o eliminar de favoritos.',
           technologies: ['Kotlin', 'Retrofit', 'Room', 'Coroutines'],
           img: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil.webp`,
           img_details: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil-detail.webp`,
           type: 'movil',
           link: '',
           app_store: 'https://newsappgalaxy.com',
           github_link: 'https://github.com/milagros-marquina-jumi/NewsAppGalaxy.com',
       }, */
    /*  {
         id: 'todo-list',
         name: 'Todo List',
         description: 'Aplicación de lista de tareas pendientes, donde puede crearlas, complementarlas y eliminarlas fácilmente.',
         technologies: ['ReactJS', 'HTML', 'CSS', 'JavaScript'],
         img: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil.webp`,
         img_details: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil-detail.webp`,
         type: 'web',
         link: '',
         app_store: 'https://restauranteesponjamovil.com',
         github_link: 'https://github.com/milagros-marquina-jumi/RestauranteEsponja.com',
     },
     {
         id: 'todo-list',
         name: 'Todo List',
         description: 'Sencilla aplicación que extrae el clima de una API.',
         technologies: ['ReactJS', 'Api'],
         img: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil.webp`,
         img_details: `${import.meta.env.BASE_URL}assets/img/projects/restauranteesponja-movil-detail.webp`,
         type: 'web',
         link: '',
         app_store: 'https://restauranteesponjamovil.com',
         github_link: 'https://github.com/milagros-marquina-jumi/RestauranteEsponja.com',
     },
     FERRETERIA!!!
     */
];

export function getAllProjects() {
    return projects;
}

export const getProjecById = (id) => {
    return projects.find(project => project.id === id);
}

export const getProjectsByType = (type) => {
    return projects.filter(project => project.type === type);
}