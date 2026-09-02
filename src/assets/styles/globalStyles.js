import { createGlobalStyle } from "styled-components";

const GlobalStyle = createGlobalStyle`

:root {
    --max-width: 1440px;
    --padding-page: 3rem;
    --header-height: 6rem;
    --section-height: calc(100vh - var(--header-height));

    --primary-color: #E7AD47;
    --secondary-color: #1F1F1F;
    --background-light-color: #544d4d;
    --background-dark-color: #424242;
    --color-green: #88aa44;

    --font-family-montserrat: "Montserrat", sans-serif;
    --font-family-reemkufi: "Reem Kufi", sans-serif;
    --font-family-raleway:"Raleway", sans-serif;
}

*,*::before,*::after,h1,h2,h3,h4,h5,h6{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    color: white;
}

#App {
    height: 100%;
}

h1,h2,h3,h4,h5,h6{
    display: inline-block;
}

*::selection {
    background-color: var(--primary-color);
    color: var(--secondary-color);
}

body::-webkit-scrollbar {
    width: 10px;
}

body::-webkit-scrollbar-thumb {
    background: var(--primary-color);
    border-radius: 20px;
    -webkit-border-radius: 20px;
    -moz-border-radius: 20px;
    -ms-border-radius: 20px;
    -o-border-radius: 20px;
}

ol,
li {
    list-style: none;
}

`

export default GlobalStyle;