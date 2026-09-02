import { createGlobalStyle } from 'styled-components'

export const lightTheme = {
    body: '#424242',
    fontColor: '#424242',
    background: '#6A6767',
    buttonproject: '#303030',
    buttonprojectHover: '#515151',
}

export const darkTheme = {
    body: '#1F1F1F',
    fontColor: '#757575',
    background: '#424242',
    buttonproject: '#424242',
    buttonprojectHover: '#282828',
}

export const GlobalTheme = createGlobalStyle`

    body {
        background-color: ${(props => props.theme.body)};
    }
    .section-about {
        background-color: ${(props) => props.theme.body};
    }
    .input-textarea {
        background-color: ${(props) => props.theme.background};
    }
    .search input {
        background-color: ${(props) => props.theme.background};
    }
    input::placeholder,
    textarea::placeholder {
        color: ${(props) => props.theme.fontColor};;
    }
    .btn-details{
        background-color: ${(props) => props.theme.buttonproject};
    }
    .project-item:hover {
        background-color: ${(props) => props.theme.buttonprojectHover};
    }
    ol.active {
        background-color: ${(props => props.theme.body)};
    }

}
`