import { describe, expect, it } from "vitest";
import en from "../translations/en/global.json";
import es from "../translations/es/global.json";

const rutas = (objeto, prefijo = "") =>
  Object.entries(objeto).flatMap(([clave, valor]) => {
    const ruta = prefijo ? `${prefijo}.${clave}` : clave;
    return valor && typeof valor === "object" && !Array.isArray(valor)
      ? rutas(valor, ruta)
      : [ruta];
  });

describe("traducciones", () => {
  const clavesEs = rutas(es);
  const clavesEn = rutas(en);

  it("el espanol y el ingles tienen exactamente las mismas claves", () => {
    expect([...clavesEn].sort()).toEqual([...clavesEs].sort());
  });

  it("no falta ninguna clave en ingles", () => {
    const faltan = clavesEs.filter((c) => !clavesEn.includes(c));
    expect(faltan).toEqual([]);
  });

  it("no sobra ninguna clave en ingles", () => {
    const sobran = clavesEn.filter((c) => !clavesEs.includes(c));
    expect(sobran).toEqual([]);
  });

  it("ningun texto esta vacio", () => {
    const leer = (objeto, ruta) =>
      ruta.split(".").reduce((valor, parte) => valor?.[parte], objeto);

    for (const idioma of [es, en]) {
      const vacias = clavesEs.filter((c) => {
        const valor = leer(idioma, c);
        return typeof valor === "string" && valor.trim() === "";
      });
      expect(vacias).toEqual([]);
    }
  });

  it("hay claves de verdad, no un fichero vacio", () => {
    expect(clavesEs.length).toBeGreaterThan(10);
  });
});
