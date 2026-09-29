---
description: Audita y corrige "AI slop" en diseño (UI, slides, diagramas) y texto, con las skills de la guía Stop AI Slop
argument-hint: "[URL|ruta|descripción|texto] [--solo-diagnostico] [--ref marca] [--dials V,M,D]"
---

# /noslop

Objetivo: que el resultado no parezca hecho por una IA con defaults. Primero se diagnostica con evidencia y después se corrige con criterio de diseñador.

Entrada: `$ARGUMENTS`

## 0. Preparación

1. Comprueba que existan las skills en `~/.claude/skills/` (`impeccable`, `ui-ux-pro-max`, `design-taste-frontend`, `redesign-existing-projects`, `stop-slop`, `humanizer`, `frontend-slides`, `diagram-design`). Si falta alguna, corre `bash ~/.claude/noslop/install.sh` (o `./install.sh` desde el repo `noslop`). Si sigue fallando, avisa qué falta y continúa con lo disponible.
2. Interpreta las opciones:
   - `--solo-diagnostico`: haz solo los pasos 1 y 2 y entrega el reporte. No edites nada.
   - `--ref <marca>`: usa `~/.claude/noslop/design-md/<marca>/DESIGN.md` como referencia de sistema visual (lista las disponibles con `ls ~/.claude/noslop/design-md`). Tómala como inspiración de rigor y no la copies. No imites una marca real en algo que no sea de esa marca.
   - `--dials V,M,D`: fija DESIGN_VARIANCE, MOTION_INTENSITY y VISUAL_DENSITY (1-10) de la skill Taste. Sin la opción, infiérelos del brief como indica esa skill.

## 1. Clasificar la entrada

| Tipo | Señal | Herramientas |
|---|---|---|
| Web/UI existente | URL, `.html`, carpeta con `src/`, componentes | Impeccable (detect + audit/critique), Taste, UI/UX Pro Max |
| UI nueva | descripción de algo por construir | UI/UX Pro Max (design system), Taste, Impeccable (shape → craft floor) |
| Slides | pide presentación, deck, `.pptx` | frontend-slides + Taste |
| Diagrama | flujo, arquitectura, proceso | diagram-design |
| Sistema de diseño | `DESIGN.md`, tokens | validador de Google (`@google/design.md`) + Impeccable `document`/`extract` |
| Texto | prosa, copy, post, email | stop-slop + humanizer |

Una entrada puede ser de varios tipos (una landing tiene UI y copy). Aplica todo lo que corresponda.

## 2. Diagnóstico (con evidencia)

**UI / web**
- Detector determinista: `npx -y impeccable detect <ruta|URL>` (o `--json`). Exit 2 = hallazgos. Si no hay navegador para la URL, descarga el HTML con curl y escanéalo.
- Revisión con criterio: sigue `impeccable` → `audit` (a11y, rendimiento, responsive) y `critique` (heurísticas UX).
- Pasa la lista de tells de `design-taste-frontend` y de `redesign-existing-projects`: gradientes morados, glows oscuros, Inter por defecto, tarjetas idénticas en rejilla de 3, emojis como íconos, bordes laterales de color, "hero centrado + 3 features", copy genérico.
- Si hay `DESIGN.md`: `npx -y @google/design.md lint DESIGN.md`.

**Texto**
- Aplica las reglas de `stop-slop` y el catálogo de patrones de `humanizer`. Marca cada hallazgo con la cita exacta y el patrón que rompe.

**Reporte** (siempre, antes de tocar nada):
```
## Diagnóstico noslop — <objetivo>
Veredicto: <parece IA / mixto / humano> — 1 frase
Hallazgos (ordenados por impacto):
1. [crítico|alto|medio] <qué> — <evidencia: regla del detector, selector, cita> — <arreglo>
Dials sugeridos: V=_, M=_, D=_  ·  Referencia: <marca o ninguna>
```
Si se pasó `--solo-diagnostico`, termina aquí.

## 3. Corrección

- **UI existente**: refinar preserva la identidad; rediseñar la reemplaza (regla de Impeccable). Pregunta si no está claro. Lee `reference/craft-floor.md` de Impeccable antes de editar. Arregla todo en un lote y no en un bucle.
- **UI nueva**: `python3 ~/.claude/skills/ui-ux-pro-max/scripts/search.py "<producto> <industria> <tono>" --design-system -p "<Nombre>"` (añade `--variance/--motion/--density` si hay dials). Construye con Taste y respeta el craft floor de Impeccable.
- **Slides**: sigue `frontend-slides` (presets de estilo, HTML con viewport fijo).
- **Diagramas**: sigue `diagram-design` (tipo semántico → tipo visual y sus anti-patrones).
- **Texto**: reescribe con `stop-slop` y pasa `humanizer`. Conserva hechos, voz y el idioma original. No inventes datos.

## 4. Verificación

- Vuelve a correr el detector o el lint sobre el resultado y muestra la comparación antes/después (número de hallazgos por severidad).
- En UI, revisa una sola ronda de capturas en desktop y móvil (Playwright/Chromium si está disponible). Corrige lo que salga y detente.
- Entrega el resumen de cambios, los hallazgos que quedan con su motivo y los archivos tocados.
