# noslop

`/noslop` es un comando de Claude Code que audita y corrige el "AI slop" en diseño (UI, slides, diagramas) y en texto. Se basa en la guía [Stop AI Slop](https://www.tododeia.com/community/stop-ai-slop#diseno).

## Instalación

```bash
git clone https://github.com/gerardovmgof/noslop && cd noslop && ./install.sh
```

Reinicia Claude Code para que aparezca `/noslop`. El instalador se puede volver a correr sin problema y también actualiza los repos. Después queda una copia en `~/.claude/noslop/install.sh`.

Qué instala:

| Repo | Uso | Destino |
|---|---|---|
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | detector (61 reglas) + audit/critique/polish | skill `impeccable` |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | buscador de estilos, paletas, tipografías, design systems | skill `ui-ux-pro-max` |
| [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | dials de diseño y lista de tells | skills `design-taste-frontend`, `redesign-existing-projects` |
| [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) | reglas anti-slop para prosa | skill `stop-slop` |
| [blader/humanizer](https://github.com/blader/humanizer) | catálogo de patrones de texto IA | skill `humanizer` |
| [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) | slides en HTML con estilo | skill `frontend-slides` |
| [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) | diagramas | skill `diagram-design` |
| [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | 74 DESIGN.md de marcas (para `--ref`) | `~/.claude/noslop/design-md/` |
| [google-labs-code/design.md](https://github.com/google-labs-code/design.md) | validador de DESIGN.md | se usa con `npx @google/design.md lint` |

Variables opcionales: `CLAUDE_CONFIG_DIR` (por defecto `~/.claude`) y `NOSLOP_CACHE` (por defecto `~/.cache/noslop/src`).

## Uso

```
/noslop [URL|ruta|descripción|texto] [--solo-diagnostico] [--ref marca] [--dials V,M,D]
```

- `/noslop https://misitio.com --solo-diagnostico`: solo entrega el reporte.
- `/noslop src/ --ref linear`: corrige usando como referencia el DESIGN.md de Linear.
- `/noslop "landing para una clínica dental" --dials 4,3,5`: diseña algo nuevo.
- `/noslop "<texto pegado>"`: reescribe el texto sin tics de IA.

El flujo tiene cuatro pasos: clasificar la entrada, diagnosticar con evidencia, corregir y verificar con una comparación antes/después.

## Claude Code en la web

Los contenedores de la web son efímeros, así que hay que correr `./install.sh` al inicio de cada sesión que tenga este repo. Para automatizarlo, añade un hook `SessionStart` en `.claude/settings.json` que ejecute `"$CLAUDE_PROJECT_DIR"/install.sh --quiet`.
